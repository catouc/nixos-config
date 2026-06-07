package models

import "time"

type Location struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Zones     []Zone    `json:"zones,omitempty"`
}

type Zone struct {
	ID         string      `json:"id"`
	LocationID string      `json:"location_id"`
	Name       string      `json:"name"`
	CreatedAt  time.Time   `json:"created_at"`
	UpdatedAt  time.Time   `json:"updated_at"`
	Containers []Container `json:"containers,omitempty"`
}

type Container struct {
	ID         string    `json:"id"`
	LocationID string    `json:"location_id"`
	ZoneID     *string   `json:"zone_id"`
	Name       string    `json:"name"`
	Notes      string    `json:"notes"`
	Type       string    `json:"type"`
	Photo      *string   `json:"photo"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
	Items      []Item    `json:"items,omitempty"`
}

type Item struct {
	ID          string    `json:"id"`
	LocationID  *string   `json:"location_id"`
	ZoneID      *string   `json:"zone_id"`
	ContainerID *string   `json:"container_id"`
	Name        string    `json:"name"`
	Quantity    *int      `json:"quantity"`
	Notes       string    `json:"notes"`
	Tags        []string  `json:"tags"`
	Photo       *string   `json:"photo"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type SearchResult struct {
	Type      string     `json:"type"` // "item" | "container"
	Item      *Item      `json:"item,omitempty"`
	Container *Container `json:"container,omitempty"`
	Path      string     `json:"path"`
}

type ExportData struct {
	Version   int        `json:"version"`
	ExportedAt time.Time `json:"exported_at"`
	Locations []Location `json:"locations"`
	Zones     []Zone     `json:"zones"`
	Containers []Container `json:"containers"`
	Items     []Item     `json:"items"`
}
