const BASE = '';

async function req(method, path, body) {
  const opts = { method, headers: {} };
  if (body !== undefined) {
    opts.headers['Content-Type'] = 'application/json';
    opts.body = JSON.stringify(body);
  }
  const res = await fetch(BASE + path, opts);
  if (res.status === 204) return null;
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || res.statusText);
  return data;
}

const api = {
  // Locations
  getLocations: () => req('GET', '/api/locations'),
  createLocation: (name) => req('POST', '/api/locations', { name }),
  updateLocation: (id, name) => req('PUT', `/api/locations/${id}`, { name }),
  deleteLocation: (id) => req('DELETE', `/api/locations/${id}`),

  // Zones
  getZones: (locationId) => req('GET', `/api/zones?location_id=${locationId}`),
  createZone: (locationId, name) => req('POST', '/api/zones', { location_id: locationId, name }),
  updateZone: (id, name) => req('PUT', `/api/zones/${id}`, { name }),
  deleteZone: (id) => req('DELETE', `/api/zones/${id}`),

  // Containers
  getContainers: (params = {}) => {
    const qs = new URLSearchParams(params).toString();
    return req('GET', `/api/containers${qs ? '?' + qs : ''}`);
  },
  getContainer: (id) => req('GET', `/api/containers/${id}`),
  createContainer: (data) => req('POST', '/api/containers', data),
  updateContainer: (id, data) => req('PUT', `/api/containers/${id}`, data),
  deleteContainer: (id) => req('DELETE', `/api/containers/${id}`),

  // Items
  getItems: (params = {}) => {
    const qs = new URLSearchParams(params).toString();
    return req('GET', `/api/items${qs ? '?' + qs : ''}`);
  },
  createItem: (data) => req('POST', '/api/items', data),
  updateItem: (id, data) => req('PUT', `/api/items/${id}`, data),
  deleteItem: (id) => req('DELETE', `/api/items/${id}`),

  // Search
  search: (q) => req('GET', `/api/search?q=${encodeURIComponent(q)}`),

  // Export/import
  exportData: () => fetch('/api/export').then(r => r.blob()),
  importData: (json) => req('POST', '/api/import', json),

  photoUrl: (filename) => filename ? `/uploads/${filename}` : null,
};
