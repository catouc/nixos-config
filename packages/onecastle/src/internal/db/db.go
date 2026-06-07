package db

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

var DB *sql.DB

func Connect(connStr string) error {
	var err error
	DB, err = sql.Open("postgres", connStr)
	if err != nil {
		return fmt.Errorf("opening db: %w", err)
	}
	if err = DB.Ping(); err != nil {
		return fmt.Errorf("pinging db: %w", err)
	}
	log.Println("Connected to PostgreSQL")
	return nil
}

func Migrate() error {
	schema := `
	CREATE TABLE IF NOT EXISTS locations (
		id UUID PRIMARY KEY,
		name TEXT NOT NULL,
		created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
		updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
	);

	CREATE TABLE IF NOT EXISTS zones (
		id UUID PRIMARY KEY,
		location_id UUID REFERENCES locations(id) ON DELETE CASCADE,
		name TEXT NOT NULL,
		created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
		updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
	);

	CREATE TABLE IF NOT EXISTS containers (
		id UUID PRIMARY KEY,
		location_id UUID REFERENCES locations(id) ON DELETE CASCADE,
		zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
		name TEXT NOT NULL,
		notes TEXT NOT NULL DEFAULT '',
		type TEXT NOT NULL DEFAULT 'box',
		photo TEXT,
		created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
		updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
	);

	CREATE TABLE IF NOT EXISTS items (
		id UUID PRIMARY KEY,
		location_id UUID REFERENCES locations(id) ON DELETE CASCADE,
		zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
		container_id UUID REFERENCES containers(id) ON DELETE CASCADE,
		name TEXT NOT NULL,
		quantity INTEGER,
		notes TEXT NOT NULL DEFAULT '',
		tags TEXT[] NOT NULL DEFAULT '{}',
		photo TEXT,
		created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
		updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
	);

	-- migrate existing tables if columns missing
	ALTER TABLE items ADD COLUMN IF NOT EXISTS tags TEXT[] NOT NULL DEFAULT '{}';

	CREATE INDEX IF NOT EXISTS idx_zones_location ON zones(location_id);
	CREATE INDEX IF NOT EXISTS idx_containers_location ON containers(location_id);
	CREATE INDEX IF NOT EXISTS idx_containers_zone ON containers(zone_id);
	CREATE INDEX IF NOT EXISTS idx_items_container ON items(container_id);
	CREATE INDEX IF NOT EXISTS idx_items_zone ON items(zone_id);
	CREATE INDEX IF NOT EXISTS idx_items_location ON items(location_id);
	`
	_, err := DB.Exec(schema)
	return err
}
