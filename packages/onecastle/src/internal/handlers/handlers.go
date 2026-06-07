package handlers

import (
	"bytes"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"image"
	"image/jpeg"
	_ "image/png"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
	"golang.org/x/image/draw"

	"onecastle/internal/db"
	"onecastle/internal/models"
)

// ── helpers ──────────────────────────────────────────────────────────────────

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}

func decode(r *http.Request, v any) error {
	return json.NewDecoder(r.Body).Decode(v)
}

var uploadDir = "./uploads"

func SetUploadDir(dir string) { uploadDir = dir }

// savePhoto accepts a base64-encoded image, resizes to max 1200px, saves as JPEG.
func savePhoto(b64 string) (string, error) {
	// strip data URI prefix if present
	if idx := strings.Index(b64, ","); idx != -1 {
		b64 = b64[idx+1:]
	}
	data, err := base64.StdEncoding.DecodeString(b64)
	if err != nil {
		return "", fmt.Errorf("base64 decode: %w", err)
	}
	src, _, err := image.Decode(bytes.NewReader(data))
	if err != nil {
		return "", fmt.Errorf("image decode: %w", err)
	}

	// Resize to max 1200px longest side
	bounds := src.Bounds()
	w, h := bounds.Dx(), bounds.Dy()
	const maxDim = 1200
	if w > maxDim || h > maxDim {
		if w > h {
			h = h * maxDim / w
			w = maxDim
		} else {
			w = w * maxDim / h
			h = maxDim
		}
	}
	dst := image.NewRGBA(image.Rect(0, 0, w, h))
	draw.BiLinear.Scale(dst, dst.Bounds(), src, src.Bounds(), draw.Over, nil)

	filename := uuid.New().String() + ".jpg"
	path := filepath.Join(uploadDir, filename)
	f, err := os.Create(path)
	if err != nil {
		return "", fmt.Errorf("create file: %w", err)
	}
	defer f.Close()
	if err := jpeg.Encode(f, dst, &jpeg.Options{Quality: 80}); err != nil {
		return "", fmt.Errorf("jpeg encode: %w", err)
	}
	return filename, nil
}

func deletePhoto(filename *string) {
	if filename == nil || *filename == "" {
		return
	}
	os.Remove(filepath.Join(uploadDir, *filename))
}

func now() time.Time { return time.Now().UTC() }

// ── LOCATIONS ────────────────────────────────────────────────────────────────

func GetLocations(w http.ResponseWriter, r *http.Request) {
	rows, err := db.DB.Query(`SELECT id, name, created_at, updated_at FROM locations ORDER BY name`)
	if err != nil {
		writeError(w, 500, err.Error())
		return
	}
	defer rows.Close()
	var locs []models.Location
	for rows.Next() {
		var l models.Location
		rows.Scan(&l.ID, &l.Name, &l.CreatedAt, &l.UpdatedAt)
		locs = append(locs, l)
	}
	if locs == nil {
		locs = []models.Location{}
	}
	writeJSON(w, 200, locs)
}

func CreateLocation(w http.ResponseWriter, r *http.Request) {
	var body struct {
		Name string `json:"name"`
	}
	if err := decode(r, &body); err != nil || strings.TrimSpace(body.Name) == "" {
		writeError(w, 400, "name required")
		return
	}
	l := models.Location{ID: uuid.New().String(), Name: strings.TrimSpace(body.Name), CreatedAt: now(), UpdatedAt: now()}
	db.DB.QueryRow(`INSERT INTO locations(id,name,created_at,updated_at) VALUES($1,$2,$3,$4) RETURNING id`, l.ID, l.Name, l.CreatedAt, l.UpdatedAt).Scan(&l.ID)
	writeJSON(w, 201, l)
}

func UpdateLocation(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var body struct{ Name string `json:"name"` }
	if err := decode(r, &body); err != nil || strings.TrimSpace(body.Name) == "" {
		writeError(w, 400, "name required")
		return
	}
	t := now()
	res, err := db.DB.Exec(`UPDATE locations SET name=$1, updated_at=$2 WHERE id=$3`, strings.TrimSpace(body.Name), t, id)
	if err != nil { writeError(w, 500, err.Error()); return }
	if n, _ := res.RowsAffected(); n == 0 { writeError(w, 404, "not found"); return }
	writeJSON(w, 200, map[string]any{"id": id, "name": body.Name, "updated_at": t})
}

func DeleteLocation(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	db.DB.Exec(`DELETE FROM locations WHERE id=$1`, id)
	w.WriteHeader(204)
}

// ── ZONES ────────────────────────────────────────────────────────────────────

func GetZones(w http.ResponseWriter, r *http.Request) {
	locationID := r.URL.Query().Get("location_id")
	var rows *sql.Rows
	var err error
	if locationID != "" {
		rows, err = db.DB.Query(`SELECT id,location_id,name,created_at,updated_at FROM zones WHERE location_id=$1 ORDER BY name`, locationID)
	} else {
		rows, err = db.DB.Query(`SELECT id,location_id,name,created_at,updated_at FROM zones ORDER BY name`)
	}
	if err != nil { writeError(w, 500, err.Error()); return }
	defer rows.Close()
	var zones []models.Zone
	for rows.Next() {
		var z models.Zone
		rows.Scan(&z.ID, &z.LocationID, &z.Name, &z.CreatedAt, &z.UpdatedAt)
		zones = append(zones, z)
	}
	if zones == nil { zones = []models.Zone{} }
	writeJSON(w, 200, zones)
}

func CreateZone(w http.ResponseWriter, r *http.Request) {
	var body struct {
		LocationID string `json:"location_id"`
		Name       string `json:"name"`
	}
	if err := decode(r, &body); err != nil || strings.TrimSpace(body.Name) == "" || body.LocationID == "" {
		writeError(w, 400, "location_id and name required")
		return
	}
	z := models.Zone{ID: uuid.New().String(), LocationID: body.LocationID, Name: strings.TrimSpace(body.Name), CreatedAt: now(), UpdatedAt: now()}
	db.DB.Exec(`INSERT INTO zones(id,location_id,name,created_at,updated_at) VALUES($1,$2,$3,$4,$5)`, z.ID, z.LocationID, z.Name, z.CreatedAt, z.UpdatedAt)
	writeJSON(w, 201, z)
}

func UpdateZone(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var body struct{ Name string `json:"name"` }
	if err := decode(r, &body); err != nil || strings.TrimSpace(body.Name) == "" {
		writeError(w, 400, "name required"); return
	}
	t := now()
	db.DB.Exec(`UPDATE zones SET name=$1, updated_at=$2 WHERE id=$3`, strings.TrimSpace(body.Name), t, id)
	writeJSON(w, 200, map[string]any{"id": id, "name": body.Name, "updated_at": t})
}

func DeleteZone(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	db.DB.Exec(`DELETE FROM zones WHERE id=$1`, id)
	w.WriteHeader(204)
}

// ── CONTAINERS ───────────────────────────────────────────────────────────────

func GetContainers(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	locID := q.Get("location_id")
	zoneID := q.Get("zone_id")

	query := `SELECT id,location_id,zone_id,name,notes,type,photo,created_at,updated_at FROM containers WHERE 1=1`
	args := []any{}
	i := 1
	if locID != "" { query += fmt.Sprintf(" AND location_id=$%d", i); args = append(args, locID); i++ }
	if zoneID != "" { query += fmt.Sprintf(" AND zone_id=$%d", i); args = append(args, zoneID); i++ }
	query += " ORDER BY name"

	rows, err := db.DB.Query(query, args...)
	if err != nil { writeError(w, 500, err.Error()); return }
	defer rows.Close()
	var containers []models.Container
	for rows.Next() {
		var c models.Container
		rows.Scan(&c.ID, &c.LocationID, &c.ZoneID, &c.Name, &c.Notes, &c.Type, &c.Photo, &c.CreatedAt, &c.UpdatedAt)
		containers = append(containers, c)
	}
	if containers == nil { containers = []models.Container{} }
	writeJSON(w, 200, containers)
}

func GetContainer(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var c models.Container
	err := db.DB.QueryRow(`SELECT id,location_id,zone_id,name,notes,type,photo,created_at,updated_at FROM containers WHERE id=$1`, id).
		Scan(&c.ID, &c.LocationID, &c.ZoneID, &c.Name, &c.Notes, &c.Type, &c.Photo, &c.CreatedAt, &c.UpdatedAt)
	if err == sql.ErrNoRows { writeError(w, 404, "not found"); return }
	if err != nil { writeError(w, 500, err.Error()); return }

	// load items
	rows, _ := db.DB.Query(`SELECT id,location_id,zone_id,container_id,name,quantity,notes,photo,created_at,updated_at FROM items WHERE container_id=$1 ORDER BY name`, id)
	defer rows.Close()
	for rows.Next() {
		var it models.Item
		rows.Scan(&it.ID, &it.LocationID, &it.ZoneID, &it.ContainerID, &it.Name, &it.Quantity, &it.Notes, &it.Photo, &it.CreatedAt, &it.UpdatedAt)
		c.Items = append(c.Items, it)
	}
	if c.Items == nil { c.Items = []models.Item{} }
	writeJSON(w, 200, c)
}

func CreateContainer(w http.ResponseWriter, r *http.Request) {
	var body struct {
		LocationID string  `json:"location_id"`
		ZoneID     *string `json:"zone_id"`
		Name       string  `json:"name"`
		Notes      string  `json:"notes"`
		Type       string  `json:"type"`
		Photo      *string `json:"photo"`
	}
	if err := decode(r, &body); err != nil || strings.TrimSpace(body.Name) == "" || body.LocationID == "" {
		writeError(w, 400, "location_id and name required"); return
	}
	if body.Type == "" { body.Type = "box" }
	c := models.Container{
		ID: uuid.New().String(), LocationID: body.LocationID, ZoneID: body.ZoneID,
		Name: strings.TrimSpace(body.Name), Notes: body.Notes, Type: body.Type,
		CreatedAt: now(), UpdatedAt: now(),
	}
	if body.Photo != nil && *body.Photo != "" {
		fn, err := savePhoto(*body.Photo)
		if err != nil { log.Println("photo save:", err) } else { c.Photo = &fn }
	}
	db.DB.Exec(`INSERT INTO containers(id,location_id,zone_id,name,notes,type,photo,created_at,updated_at) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
		c.ID, c.LocationID, c.ZoneID, c.Name, c.Notes, c.Type, c.Photo, c.CreatedAt, c.UpdatedAt)
	writeJSON(w, 201, c)
}

func UpdateContainer(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var body struct {
		Name   string  `json:"name"`
		Notes  string  `json:"notes"`
		Type   string  `json:"type"`
		ZoneID *string `json:"zone_id"`
		Photo  *string `json:"photo"` // base64 new photo, or "" to remove, or nil to keep
	}
	if err := decode(r, &body); err != nil { writeError(w, 400, "invalid body"); return }

	// fetch existing
	var c models.Container
	db.DB.QueryRow(`SELECT id,photo FROM containers WHERE id=$1`, id).Scan(&c.ID, &c.Photo)

	newPhoto := c.Photo
	if body.Photo != nil {
		if *body.Photo == "" {
			deletePhoto(c.Photo)
			newPhoto = nil
		} else {
			deletePhoto(c.Photo)
			fn, err := savePhoto(*body.Photo)
			if err != nil { log.Println("photo save:", err) } else { newPhoto = &fn }
		}
	}

	t := now()
	db.DB.Exec(`UPDATE containers SET name=$1,notes=$2,type=$3,zone_id=$4,photo=$5,updated_at=$6 WHERE id=$7`,
		strings.TrimSpace(body.Name), body.Notes, body.Type, body.ZoneID, newPhoto, t, id)
	writeJSON(w, 200, map[string]any{"id": id, "updated_at": t})
}

func DeleteContainer(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var photo *string
	db.DB.QueryRow(`SELECT photo FROM containers WHERE id=$1`, id).Scan(&photo)
	deletePhoto(photo)
	db.DB.Exec(`DELETE FROM containers WHERE id=$1`, id)
	w.WriteHeader(204)
}

// ── ITEMS ────────────────────────────────────────────────────────────────────

func GetItems(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	containerID := q.Get("container_id")
	zoneID := q.Get("zone_id")
	locationID := q.Get("location_id")

	query := `SELECT id,location_id,zone_id,container_id,name,quantity,notes,tags,photo,created_at,updated_at FROM items WHERE 1=1`
	args := []any{}
	i := 1
	if containerID != "" { query += fmt.Sprintf(" AND container_id=$%d", i); args = append(args, containerID); i++ }
	if zoneID != "" { query += fmt.Sprintf(" AND zone_id=$%d", i); args = append(args, zoneID); i++ }
	if locationID != "" { query += fmt.Sprintf(" AND location_id=$%d", i); args = append(args, locationID); i++ }
	query += " ORDER BY name"

	rows, err := db.DB.Query(query, args...)
	if err != nil { writeError(w, 500, err.Error()); return }
	defer rows.Close()
	var items []models.Item
	for rows.Next() {
		var it models.Item
		var tags pq.StringArray
		rows.Scan(&it.ID, &it.LocationID, &it.ZoneID, &it.ContainerID, &it.Name, &it.Quantity, &it.Notes, &tags, &it.Photo, &it.CreatedAt, &it.UpdatedAt)
		it.Tags = []string(tags)
		if it.Tags == nil { it.Tags = []string{} }
		items = append(items, it)
	}
	if items == nil { items = []models.Item{} }
	writeJSON(w, 200, items)
}

func CreateItem(w http.ResponseWriter, r *http.Request) {
	var body struct {
		LocationID  *string  `json:"location_id"`
		ZoneID      *string  `json:"zone_id"`
		ContainerID *string  `json:"container_id"`
		Name        string   `json:"name"`
		Quantity    *int     `json:"quantity"`
		Notes       string   `json:"notes"`
		Tags        []string `json:"tags"`
		Photo       *string  `json:"photo"`
	}
	if err := decode(r, &body); err != nil || strings.TrimSpace(body.Name) == "" {
		writeError(w, 400, "name required"); return
	}
	if body.Tags == nil { body.Tags = []string{} }
	it := models.Item{
		ID: uuid.New().String(), LocationID: body.LocationID, ZoneID: body.ZoneID,
		ContainerID: body.ContainerID, Name: strings.TrimSpace(body.Name),
		Quantity: body.Quantity, Notes: body.Notes, Tags: body.Tags,
		CreatedAt: now(), UpdatedAt: now(),
	}
	if body.Photo != nil && *body.Photo != "" {
		fn, err := savePhoto(*body.Photo)
		if err != nil { log.Println("photo save:", err) } else { it.Photo = &fn }
	}
	db.DB.Exec(`INSERT INTO items(id,location_id,zone_id,container_id,name,quantity,notes,tags,photo,created_at,updated_at) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)`,
		it.ID, it.LocationID, it.ZoneID, it.ContainerID, it.Name, it.Quantity, it.Notes, pq.Array(it.Tags), it.Photo, it.CreatedAt, it.UpdatedAt)
	writeJSON(w, 201, it)
}

func UpdateItem(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var body struct {
		Name        string   `json:"name"`
		Quantity    *int     `json:"quantity"`
		Notes       string   `json:"notes"`
		Tags        []string `json:"tags"`
		ContainerID *string  `json:"container_id"`
		ZoneID      *string  `json:"zone_id"`
		LocationID  *string  `json:"location_id"`
		Photo       *string  `json:"photo"`
	}
	if err := decode(r, &body); err != nil { writeError(w, 400, "invalid body"); return }
	if body.Tags == nil { body.Tags = []string{} }

	var existing models.Item
	db.DB.QueryRow(`SELECT photo FROM items WHERE id=$1`, id).Scan(&existing.Photo)

	newPhoto := existing.Photo
	if body.Photo != nil {
		if *body.Photo == "" {
			deletePhoto(existing.Photo)
			newPhoto = nil
		} else {
			deletePhoto(existing.Photo)
			fn, err := savePhoto(*body.Photo)
			if err != nil { log.Println("photo save:", err) } else { newPhoto = &fn }
		}
	}

	t := now()
	db.DB.Exec(`UPDATE items SET name=$1,quantity=$2,notes=$3,tags=$4,container_id=$5,zone_id=$6,location_id=$7,photo=$8,updated_at=$9 WHERE id=$10`,
		strings.TrimSpace(body.Name), body.Quantity, body.Notes, pq.Array(body.Tags), body.ContainerID, body.ZoneID, body.LocationID, newPhoto, t, id)
	writeJSON(w, 200, map[string]any{"id": id, "updated_at": t})
}

func DeleteItem(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var photo *string
	db.DB.QueryRow(`SELECT photo FROM items WHERE id=$1`, id).Scan(&photo)
	deletePhoto(photo)
	db.DB.Exec(`DELETE FROM items WHERE id=$1`, id)
	w.WriteHeader(204)
}

// ── SEARCH ───────────────────────────────────────────────────────────────────

func Search(w http.ResponseWriter, r *http.Request) {
	q := strings.TrimSpace(r.URL.Query().Get("q"))
	if q == "" { writeJSON(w, 200, []any{}); return }
	pattern := "%" + strings.ToLower(q) + "%"

	var results []models.SearchResult

	// search items
	rows, _ := db.DB.Query(`
		SELECT i.id,i.location_id,i.zone_id,i.container_id,i.name,i.quantity,i.notes,i.tags,i.photo,i.created_at,i.updated_at,
		       l.name, z.name, c.name
		FROM items i
		LEFT JOIN locations l ON l.id = i.location_id
		LEFT JOIN zones z ON z.id = i.zone_id
		LEFT JOIN containers c ON c.id = i.container_id
		WHERE LOWER(i.name) LIKE $1 OR LOWER(i.notes) LIKE $1 OR EXISTS (
			SELECT 1 FROM unnest(i.tags) t WHERE LOWER(t) LIKE $1
		)
		ORDER BY i.name LIMIT 50`, pattern)
	defer rows.Close()
	for rows.Next() {
		var it models.Item
		var tags pq.StringArray
		var locName, zoneName, conName sql.NullString
		rows.Scan(&it.ID, &it.LocationID, &it.ZoneID, &it.ContainerID, &it.Name, &it.Quantity, &it.Notes, &tags, &it.Photo, &it.CreatedAt, &it.UpdatedAt,
			&locName, &zoneName, &conName)
		it.Tags = []string(tags)
		if it.Tags == nil { it.Tags = []string{} }
		path := buildPath(locName, zoneName, conName)
		results = append(results, models.SearchResult{Type: "item", Item: &it, Path: path})
	}

	// search containers
	rows2, _ := db.DB.Query(`
		SELECT c.id,c.location_id,c.zone_id,c.name,c.notes,c.type,c.photo,c.created_at,c.updated_at,
		       l.name, z.name
		FROM containers c
		LEFT JOIN locations l ON l.id = c.location_id
		LEFT JOIN zones z ON z.id = c.zone_id
		WHERE LOWER(c.name) LIKE $1 OR LOWER(c.notes) LIKE $1
		ORDER BY c.name LIMIT 50`, pattern)
	defer rows2.Close()
	for rows2.Next() {
		var c models.Container
		var locName, zoneName sql.NullString
		rows2.Scan(&c.ID, &c.LocationID, &c.ZoneID, &c.Name, &c.Notes, &c.Type, &c.Photo, &c.CreatedAt, &c.UpdatedAt, &locName, &zoneName)
		path := buildPath(locName, zoneName, sql.NullString{})
		results = append(results, models.SearchResult{Type: "container", Container: &c, Path: path})
	}

	if results == nil { results = []models.SearchResult{} }
	writeJSON(w, 200, results)
}

func buildPath(loc, zone, container sql.NullString) string {
	parts := []string{}
	if loc.Valid && loc.String != "" { parts = append(parts, loc.String) }
	if zone.Valid && zone.String != "" { parts = append(parts, zone.String) }
	if container.Valid && container.String != "" { parts = append(parts, container.String) }
	return strings.Join(parts, " › ")
}

// ── PHOTOS ───────────────────────────────────────────────────────────────────

func ServePhoto(w http.ResponseWriter, r *http.Request) {
	filename := r.PathValue("filename")
	// sanitize
	filename = filepath.Base(filename)
	path := filepath.Join(uploadDir, filename)
	http.ServeFile(w, r, path)
}

// ── EXPORT / IMPORT ──────────────────────────────────────────────────────────

func Export(w http.ResponseWriter, r *http.Request) {
	export := models.ExportData{Version: 1, ExportedAt: now()}

	rows, _ := db.DB.Query(`SELECT id,name,created_at,updated_at FROM locations ORDER BY name`)
	defer rows.Close()
	for rows.Next() {
		var l models.Location
		rows.Scan(&l.ID, &l.Name, &l.CreatedAt, &l.UpdatedAt)
		export.Locations = append(export.Locations, l)
	}

	rows2, _ := db.DB.Query(`SELECT id,location_id,name,created_at,updated_at FROM zones ORDER BY name`)
	defer rows2.Close()
	for rows2.Next() {
		var z models.Zone
		rows2.Scan(&z.ID, &z.LocationID, &z.Name, &z.CreatedAt, &z.UpdatedAt)
		export.Zones = append(export.Zones, z)
	}

	rows3, _ := db.DB.Query(`SELECT id,location_id,zone_id,name,notes,type,photo,created_at,updated_at FROM containers ORDER BY name`)
	defer rows3.Close()
	for rows3.Next() {
		var c models.Container
		rows3.Scan(&c.ID, &c.LocationID, &c.ZoneID, &c.Name, &c.Notes, &c.Type, &c.Photo, &c.CreatedAt, &c.UpdatedAt)
		export.Containers = append(export.Containers, c)
	}

	rows4, _ := db.DB.Query(`SELECT id,location_id,zone_id,container_id,name,quantity,notes,tags,photo,created_at,updated_at FROM items ORDER BY name`)
	defer rows4.Close()
	for rows4.Next() {
		var it models.Item
		var tags pq.StringArray
		rows4.Scan(&it.ID, &it.LocationID, &it.ZoneID, &it.ContainerID, &it.Name, &it.Quantity, &it.Notes, &tags, &it.Photo, &it.CreatedAt, &it.UpdatedAt)
		it.Tags = []string(tags)
		if it.Tags == nil { it.Tags = []string{} }
		export.Items = append(export.Items, it)
	}

	w.Header().Set("Content-Disposition", `attachment; filename="onecastle-export.json"`)
	writeJSON(w, 200, export)
}

func Import(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(r.Body)
	if err != nil { writeError(w, 400, "cannot read body"); return }
	var data models.ExportData
	if err := json.Unmarshal(body, &data); err != nil { writeError(w, 400, "invalid JSON"); return }

	tx, err := db.DB.Begin()
	if err != nil { writeError(w, 500, err.Error()); return }
	defer tx.Rollback()

	for _, l := range data.Locations {
		tx.Exec(`INSERT INTO locations(id,name,created_at,updated_at) VALUES($1,$2,$3,$4) ON CONFLICT(id) DO UPDATE SET name=$2,updated_at=$4`, l.ID, l.Name, l.CreatedAt, l.UpdatedAt)
	}
	for _, z := range data.Zones {
		tx.Exec(`INSERT INTO zones(id,location_id,name,created_at,updated_at) VALUES($1,$2,$3,$4,$5) ON CONFLICT(id) DO UPDATE SET name=$3,updated_at=$5`, z.ID, z.LocationID, z.Name, z.CreatedAt, z.UpdatedAt)
	}
	for _, c := range data.Containers {
		tx.Exec(`INSERT INTO containers(id,location_id,zone_id,name,notes,type,photo,created_at,updated_at) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9) ON CONFLICT(id) DO UPDATE SET name=$4,notes=$5,updated_at=$9`, c.ID, c.LocationID, c.ZoneID, c.Name, c.Notes, c.Type, c.Photo, c.CreatedAt, c.UpdatedAt)
	}
	for _, it := range data.Items {
		if it.Tags == nil { it.Tags = []string{} }
		tx.Exec(`INSERT INTO items(id,location_id,zone_id,container_id,name,quantity,notes,tags,photo,created_at,updated_at) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11) ON CONFLICT(id) DO UPDATE SET name=$5,quantity=$6,notes=$7,tags=$8,updated_at=$11`, it.ID, it.LocationID, it.ZoneID, it.ContainerID, it.Name, it.Quantity, it.Notes, pq.Array(it.Tags), it.Photo, it.CreatedAt, it.UpdatedAt)
	}

	if err := tx.Commit(); err != nil { writeError(w, 500, err.Error()); return }
	writeJSON(w, 200, map[string]string{"status": "imported"})
}
