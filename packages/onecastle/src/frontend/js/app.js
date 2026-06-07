// ── State ─────────────────────────────────────────────────────────────────────
const state = {
  tab: 'home',       // home | search
  stack: [],         // navigation stack: [{type, data}]
};

// ── Router ────────────────────────────────────────────────────────────────────
function push(type, data) {
  state.stack.push({ type, data });
  render();
}

function pop() {
  state.stack.pop();
  render();
}

function popTo(index) {
  state.stack = state.stack.slice(0, index + 1);
  render();
}

function setTab(tab) {
  state.tab = tab;
  state.stack = [];
  render();
}

// ── Main render ───────────────────────────────────────────────────────────────
function render() {
  const app = document.getElementById('app');
  app.innerHTML = '';

  if (state.tab === 'search') {
    app.appendChild(buildSearchView());
    app.appendChild(buildTabBar());
    return;
  }

  // Home tab
  const current = state.stack[state.stack.length - 1];
  if (!current) {
    app.appendChild(buildHomeView());
  } else if (current.type === 'location') {
    app.appendChild(buildLocationView(current.data));
  } else if (current.type === 'zone') {
    app.appendChild(buildZoneView(current.data));
  } else if (current.type === 'container') {
    app.appendChild(buildContainerView(current.data));
  }
  app.appendChild(buildTabBar());
}

// ── Tab bar ───────────────────────────────────────────────────────────────────
function buildTabBar() {
  const bar = document.createElement('div');
  bar.className = 'tab-bar';
  bar.innerHTML = `
    <button class="tab-btn ${state.tab === 'home' ? 'active' : ''}" data-tab="home">
      ${IC.home}<span>Home</span>
    </button>
    <button class="tab-btn ${state.tab === 'search' ? 'active' : ''}" data-tab="search">
      ${IC.search}<span>Search</span>
    </button>`;
  bar.querySelectorAll('.tab-btn').forEach(b =>
    b.addEventListener('click', () => setTab(b.dataset.tab))
  );
  return bar;
}

// ── Top bar ───────────────────────────────────────────────────────────────────
function buildTopBar({ title, backLabel, actions = [] }) {
  const bar = document.createElement('div');
  bar.className = 'top-bar';
  if (backLabel !== undefined) {
    const back = document.createElement('button');
    back.className = 'back-btn';
    back.innerHTML = `${IC.back}<span>${backLabel}</span>`;
    back.onclick = pop;
    bar.appendChild(back);
  }
  const h1 = document.createElement('h1');
  h1.textContent = title;
  bar.appendChild(h1);
  const actDiv = document.createElement('div');
  actDiv.className = 'actions';
  actions.forEach(({ icon, onClick, label }) => {
    const btn = document.createElement('button');
    btn.className = 'btn-icon';
    btn.innerHTML = icon;
    btn.setAttribute('aria-label', label || '');
    btn.onclick = onClick;
    actDiv.appendChild(btn);
  });
  bar.appendChild(actDiv);
  return bar;
}

// ── HOME VIEW (locations list) ────────────────────────────────────────────────
function buildHomeView() {
  const wrap = document.createElement('div');
  wrap.id = 'view-home';

  const header = document.createElement('div');
  header.className = 'top-bar';
  header.innerHTML = `
    <div style="flex:1">
      <div class="app-header" style="padding:0">
        <div class="wordmark">One<span>Castle</span></div>
      </div>
    </div>`;
  const actDiv = document.createElement('div');
  actDiv.className = 'actions';

  const exportBtn = document.createElement('button');
  exportBtn.className = 'btn-icon'; exportBtn.innerHTML = IC.export; exportBtn.title = 'Export';
  exportBtn.onclick = doExport;
  const importBtn = document.createElement('button');
  importBtn.className = 'btn-icon'; importBtn.innerHTML = IC.upload; importBtn.title = 'Import';
  importBtn.onclick = doImport;
  const addBtn = document.createElement('button');
  addBtn.className = 'btn-icon'; addBtn.innerHTML = IC.plus; addBtn.title = 'Add location';
  addBtn.onclick = () => showLocationForm();

  actDiv.append(exportBtn, importBtn, addBtn);
  header.appendChild(actDiv);
  wrap.appendChild(header);

  const content = document.createElement('div');
  content.className = 'content';
  content.innerHTML = '<div class="loading-center"><div class="spinner"></div></div>';
  wrap.appendChild(content);

  api.getLocations().then(locs => {
    content.innerHTML = '';
    if (!locs.length) {
      content.innerHTML = `<div class="empty-state">${IC.map}<h3>No Locations</h3><p>Add your first location to get started.</p></div>`;
      return;
    }
    const sorted = naturalSort(locs, 'name');
    const card = document.createElement('div');
    card.className = 'card';
    card.style.marginTop = '12px';
    sorted.forEach(loc => {
      const row = document.createElement('div');
      row.className = 'card-row';
      row.innerHTML = `
        <div class="row-icon">${IC.map}</div>
        <div class="row-body">
          <div class="row-title">${loc.name}</div>
        </div>
        <div class="row-chevron">${IC.chevron}</div>`;
      row.addEventListener('click', () => push('location', loc));
      // long-press for edit/delete
      addLongPress(row, () => showLocationActions(loc));
      card.appendChild(row);
    });
    content.appendChild(card);
  }).catch(e => { content.innerHTML = `<div class="empty-state"><p>Error: ${e.message}</p></div>`; });

  return wrap;
}

// ── LOCATION VIEW (zones + loose containers + loose items) ────────────────────
function buildLocationView(location) {
  const wrap = document.createElement('div');

  wrap.appendChild(buildTopBar({
    title: location.name,
    backLabel: 'Locations',
    actions: [
      { icon: IC.edit, label: 'Edit', onClick: () => showLocationForm(location) },
      { icon: IC.plus, label: 'Add', onClick: () => showAddInLocationMenu(location) },
    ]
  }));

  const content = document.createElement('div');
  content.className = 'content';
  wrap.appendChild(content);

  loadLocationContent(content, location);
  return wrap;
}

async function loadLocationContent(content, location) {
  content.innerHTML = '<div class="loading-center"><div class="spinner"></div></div>';
  try {
    const [zones, containers, items] = await Promise.all([
      api.getZones(location.id),
      api.getContainers({ location_id: location.id }),
      api.getItems({ location_id: location.id }),
    ]);

    // loose = not assigned to a zone
    const looseContainers = containers.filter(c => !c.zone_id);
    const looseItems = items.filter(i => !i.zone_id && !i.container_id);

    content.innerHTML = '';

    if (!zones.length && !looseContainers.length && !looseItems.length) {
      content.innerHTML = `<div class="empty-state">${IC.zone}<h3>Empty Location</h3><p>Add zones, containers, or items directly here.</p></div>`;
      return;
    }

    // Zones
    if (zones.length) {
      const hdr = document.createElement('div');
      hdr.className = 'section-header'; hdr.textContent = 'Zones';
      content.appendChild(hdr);
      const card = document.createElement('div');
      card.className = 'card';
      naturalSort(zones, 'name').forEach(z => {
        const row = document.createElement('div');
        row.className = 'card-row';
        row.innerHTML = `
          <div class="row-icon">${IC.zone}</div>
          <div class="row-body"><div class="row-title">${z.name}</div></div>
          <div class="row-chevron">${IC.chevron}</div>`;
        row.onclick = () => push('zone', { ...z, location });
        addLongPress(row, () => showZoneActions(z, location, content));
        card.appendChild(row);
      });
      content.appendChild(card);
    }

    // Loose containers
    if (looseContainers.length) {
      const hdr = document.createElement('div');
      hdr.className = 'section-header'; hdr.textContent = 'Containers';
      content.appendChild(hdr);
      const card = document.createElement('div');
      card.className = 'card';
      naturalSort(looseContainers, 'name').forEach(c => {
        content.appendChild(card);
        appendContainerRow(card, c, location, null);
      });
      content.appendChild(card);
    }

    // Loose items
    if (looseItems.length) {
      const hdr = document.createElement('div');
      hdr.className = 'section-header'; hdr.textContent = 'Items';
      content.appendChild(hdr);
      const card = document.createElement('div');
      card.className = 'card';
      naturalSort(looseItems, 'name').forEach(it => appendItemRow(card, it, () => loadLocationContent(content, location)));
      content.appendChild(card);
    }

  } catch (e) {
    content.innerHTML = `<div class="empty-state"><p>Error: ${e.message}</p></div>`;
  }
}

// ── ZONE VIEW ─────────────────────────────────────────────────────────────────
function buildZoneView(zone) {
  const wrap = document.createElement('div');
  wrap.appendChild(buildTopBar({
    title: zone.name,
    backLabel: zone.location?.name || 'Back',
    actions: [
      { icon: IC.edit, label: 'Edit', onClick: () => showZoneForm(zone.location, zone) },
      { icon: IC.plus, label: 'Add', onClick: () => showAddInZoneMenu(zone) },
    ]
  }));

  const content = document.createElement('div');
  content.className = 'content';
  wrap.appendChild(content);
  loadZoneContent(content, zone);
  return wrap;
}

async function loadZoneContent(content, zone) {
  content.innerHTML = '<div class="loading-center"><div class="spinner"></div></div>';
  try {
    const [containers, items] = await Promise.all([
      api.getContainers({ zone_id: zone.id }),
      api.getItems({ zone_id: zone.id }),
    ]);
    const looseItems = items.filter(i => !i.container_id);

    content.innerHTML = '';

    if (!containers.length && !looseItems.length) {
      content.innerHTML = `<div class="empty-state">${IC.box}<h3>Empty Zone</h3><p>Add containers or items here.</p></div>`;
      return;
    }

    if (containers.length) {
      const hdr = document.createElement('div'); hdr.className = 'section-header'; hdr.textContent = 'Containers';
      content.appendChild(hdr);
      const card = document.createElement('div'); card.className = 'card';
      naturalSort(containers, 'name').forEach(c => appendContainerRow(card, c, zone.location, zone));
      content.appendChild(card);
    }

    if (looseItems.length) {
      const hdr = document.createElement('div'); hdr.className = 'section-header'; hdr.textContent = 'Items';
      content.appendChild(hdr);
      const card = document.createElement('div'); card.className = 'card';
      naturalSort(looseItems, 'name').forEach(it => appendItemRow(card, it, () => loadZoneContent(content, zone)));
      content.appendChild(card);
    }
  } catch (e) {
    content.innerHTML = `<div class="empty-state"><p>Error: ${e.message}</p></div>`;
  }
}

// ── CONTAINER VIEW ────────────────────────────────────────────────────────────
function buildContainerView(container) {
  const wrap = document.createElement('div');

  // determine back label
  const backLabel = container._zone?.name || container._location?.name || 'Back';

  wrap.appendChild(buildTopBar({
    title: container.name,
    backLabel,
    actions: [
      { icon: IC.edit, label: 'Edit', onClick: () => showContainerForm(container._location, container._zone, container, () => {
        // refresh
        api.getContainer(container.id).then(c => {
          c._location = container._location; c._zone = container._zone;
          state.stack[state.stack.length - 1].data = c;
          render();
        });
      })},
    ]
  }));

  const content = document.createElement('div');
  content.className = 'content';
  wrap.appendChild(content);
  loadContainerContent(content, container);
  return wrap;
}

async function loadContainerContent(content, container) {
  content.innerHTML = '<div class="loading-center"><div class="spinner"></div></div>';
  try {
    const full = await api.getContainer(container.id);
    full._location = container._location;
    full._zone = container._zone;
    // update stack
    state.stack[state.stack.length - 1].data = full;

    content.innerHTML = '';

    // Hero photo
    const heroWrap = document.createElement('div');
    heroWrap.className = 'card';
    heroWrap.style.marginTop = '12px';
    if (full.photo) {
      heroWrap.innerHTML = `<img class="hero-photo" src="${api.photoUrl(full.photo)}" alt="">`;
    }
    const heroInfo = document.createElement('div');
    heroInfo.className = 'hero-info';
    heroInfo.innerHTML = `
      <div class="hero-name">${full.name}</div>
      <div class="hero-meta">
        <span class="pill pill-subtle">${full.type}</span>
      </div>
      ${full.notes ? `<div class="hero-path" style="margin-top:8px">${full.notes}</div>` : ''}
      <div class="hero-path">${buildPath(full)}</div>`;
    heroWrap.appendChild(heroInfo);
    content.appendChild(heroWrap);

    // Items
    const itemsHdr = document.createElement('div');
    itemsHdr.className = 'section-header';
    itemsHdr.innerHTML = `ITEMS`;
    content.appendChild(itemsHdr);

    const itemsCard = document.createElement('div');
    itemsCard.className = 'card';

    const sorted = naturalSort(full.items || [], 'name');
    sorted.forEach(it => appendItemRow(itemsCard, it, () => loadContainerContent(content, full)));

    // Add item row
    const addRow = document.createElement('div');
    addRow.className = 'action-row';
    addRow.innerHTML = `${IC.plus}<span>Add item</span>`;
    addRow.onclick = () => showItemForm(full, null, () => loadContainerContent(content, full));
    itemsCard.appendChild(addRow);
    content.appendChild(itemsCard);

    // Actions
    const actHdr = document.createElement('div');
    actHdr.className = 'section-header'; actHdr.textContent = 'ACTIONS';
    content.appendChild(actHdr);
    const actCard = document.createElement('div');
    actCard.className = 'card';
    const delRow = document.createElement('div');
    delRow.className = 'action-row danger';
    delRow.innerHTML = `${IC.trash}<span>Delete Container</span>`;
    delRow.onclick = async () => {
      const ok = await showConfirm({ title: `Delete "${full.name}"?`, message: `This will delete all ${full.items.length} items inside.` });
      if (!ok) return;
      await api.deleteContainer(full.id);
      showToast('Container deleted');
      pop();
    };
    actCard.appendChild(delRow);
    content.appendChild(actCard);

  } catch (e) {
    content.innerHTML = `<div class="empty-state"><p>Error: ${e.message}</p></div>`;
  }
}

function buildPath(container) {
  const parts = [];
  if (container._location) parts.push(container._location.name);
  if (container._zone) parts.push(container._zone.name);
  return parts.join(' › ');
}

// ── Row helpers ───────────────────────────────────────────────────────────────
function appendContainerRow(card, c, location, zone) {
  const row = document.createElement('div');
  row.className = 'card-row';
  row.innerHTML = `
    ${c.photo ? `<img class="row-thumb" src="${api.photoUrl(c.photo)}" alt="">` : `<div class="row-icon">${IC.box}</div>`}
    <div class="row-body">
      <div class="row-title">${c.name}</div>
      ${c.notes ? `<div class="row-sub">${c.notes}</div>` : ''}
    </div>
    <div class="row-chevron">${IC.chevron}</div>`;
  row.onclick = () => push('container', { ...c, _location: location, _zone: zone });
  addLongPress(row, () => showContainerActions(c, location, zone));
  card.appendChild(row);
}

function appendItemRow(card, item, onRefresh) {
  const row = document.createElement('div');
  row.className = 'card-row';
  row.innerHTML = `
    ${item.photo ? `<img class="row-thumb" src="${api.photoUrl(item.photo)}" alt="">` : `<div class="row-icon">${IC.item}</div>`}
    <div class="row-body">
      <div class="row-title">${item.name}</div>
      ${item.notes ? `<div class="row-sub">${item.notes}</div>` : ''}
    </div>
    <div class="row-meta">
      ${item.quantity != null ? `<div class="qty-badge">×${item.quantity}</div>` : ''}
      <div class="row-chevron">${IC.chevron}</div>
    </div>`;
  row.onclick = () => showItemForm(null, item, onRefresh);
  addLongPress(row, () => showItemActions(item, onRefresh));
  card.appendChild(row);
}

// ── SEARCH VIEW ───────────────────────────────────────────────────────────────
function buildSearchView() {
  const wrap = document.createElement('div');
  wrap.id = 'view-search';

  const topBar = document.createElement('div');
  topBar.className = 'top-bar';
  topBar.innerHTML = `<h1>Search</h1>`;
  wrap.appendChild(topBar);

  const content = document.createElement('div');
  content.className = 'content';
  content.style.paddingTop = '12px';

  const searchBar = document.createElement('div');
  searchBar.className = 'search-bar';
  searchBar.innerHTML = `${IC.search}<input type="search" placeholder="Search items, containers, notes…" autocomplete="off">`;
  content.appendChild(searchBar);

  const results = document.createElement('div');
  content.appendChild(results);
  wrap.appendChild(content);

  let timer;
  const input = searchBar.querySelector('input');
  input.addEventListener('input', () => {
    clearTimeout(timer);
    const q = input.value.trim();
    if (!q) { results.innerHTML = ''; return; }
    timer = setTimeout(async () => {
      const data = await api.search(q);
      results.innerHTML = '';
      if (!data.length) {
        results.innerHTML = `<div class="empty-state" style="padding:32px 0">${IC.search}<p>No results for "${q}"</p></div>`;
        return;
      }
      const card = document.createElement('div');
      card.className = 'card';
      data.forEach(r => {
        const row = document.createElement('div');
        row.className = 'card-row';
        const isItem = r.type === 'item';
        const name = isItem ? r.item.name : r.container.name;
        const photo = isItem ? r.item.photo : r.container.photo;
        const qty = isItem && r.item.quantity != null ? `×${r.item.quantity}` : '';
        row.innerHTML = `
          ${photo ? `<img class="row-thumb" src="${api.photoUrl(photo)}" alt="">` : `<div class="row-icon">${isItem ? IC.item : IC.box}</div>`}
          <div class="row-body">
            <div class="row-title">${name}</div>
            <div class="row-sub">${r.path}</div>
          </div>
          ${qty ? `<div class="qty-badge">${qty}</div>` : ''}`;
        if (!isItem) {
          row.onclick = () => {
            state.tab = 'home';
            // navigate to container
            navigateToContainer(r.container);
          };
        }
        card.appendChild(row);
      });
      results.appendChild(card);
    }, 300);
  });

  setTimeout(() => input.focus(), 100);
  return wrap;
}

async function navigateToContainer(container) {
  state.stack = [];
  render();
  // We need location info
  const locs = await api.getLocations();
  const loc = locs.find(l => l.id === container.location_id);
  if (loc) state.stack.push({ type: 'location', data: loc });
  if (container.zone_id) {
    const zones = await api.getZones(container.location_id);
    const zone = zones.find(z => z.id === container.zone_id);
    if (zone) state.stack.push({ type: 'zone', data: { ...zone, location: loc } });
  }
  const full = await api.getContainer(container.id);
  full._location = loc;
  state.stack.push({ type: 'container', data: full });
  render();
}

// ── FORMS ─────────────────────────────────────────────────────────────────────

function showLocationForm(location = null) {
  const isEdit = !!location;
  const { el, close } = createModal({
    title: isEdit ? 'Edit Location' : 'New Location',
    body: `
      <div class="form-group">
        <label class="form-label">Name</label>
        <input class="form-input" id="loc-name" value="${location?.name || ''}" placeholder="e.g. Basement" autofocus>
      </div>`,
    footer: `<button class="btn btn-primary" style="width:100%" id="loc-save">${isEdit ? 'Save' : 'Add Location'}</button>`,
  });

  el.querySelector('#loc-save').onclick = async () => {
    const name = el.querySelector('#loc-name').value.trim();
    if (!name) return;
    if (isEdit) {
      await api.updateLocation(location.id, name);
      showToast('Location updated');
      // update stack if we're viewing it
      const cur = state.stack[state.stack.length - 1];
      if (cur?.type === 'location') { cur.data.name = name; }
    } else {
      await api.createLocation(name);
      showToast('Location added');
    }
    close();
    render();
  };

  setTimeout(() => el.querySelector('#loc-name').focus(), 100);
}

function showZoneForm(location, zone = null) {
  const isEdit = !!zone;
  const { el, close } = createModal({
    title: isEdit ? 'Edit Zone' : 'New Zone',
    body: `
      <div class="form-group">
        <label class="form-label">Name</label>
        <input class="form-input" id="zone-name" value="${zone?.name || ''}" placeholder="e.g. Shelving Unit A">
      </div>`,
    footer: `<button class="btn btn-primary" style="width:100%" id="zone-save">${isEdit ? 'Save' : 'Add Zone'}</button>`,
  });

  el.querySelector('#zone-save').onclick = async () => {
    const name = el.querySelector('#zone-name').value.trim();
    if (!name) return;
    if (isEdit) {
      await api.updateZone(zone.id, name);
      showToast('Zone updated');
    } else {
      await api.createZone(location.id, name);
      showToast('Zone added');
    }
    close();
    // refresh current view
    refreshCurrentView();
  };

  setTimeout(() => el.querySelector('#zone-name').focus(), 100);
}


// ── LocationPicker widget ─────────────────────────────────────────────────────
// Renders pill-based location selector: Location > Zone > Container (all optional)
// onChange(location, zone, container) called whenever selection changes.
class LocationPicker {
  constructor(el, initial = {}, onChange) {
    this.el = el;
    this.location = initial.location || null;
    this.zone = initial.zone || null;
    this.container = initial.container || null;
    this.onChange = onChange;
    this.render();
  }

  render() {
    this.el.innerHTML = `<div class="loc-pills" id="lp-pills"></div><div class="loc-dropdown" id="lp-dropdown" style="display:none"></div>`;
    this._renderPills();
  }

  _renderPills() {
    const pills = this.el.querySelector('#lp-pills');
    pills.innerHTML = '';

    const make = (label, value, level) => {
      const pill = document.createElement('span');
      pill.className = `loc-pill loc-pill-${level}${value ? ' filled' : ' empty'}`;
      pill.innerHTML = `${label}: <strong>${value || 'None'}</strong>`;
      pill.onclick = () => this._openDropdown(level);
      return pill;
    };

    pills.appendChild(make('Location', this.location?.name, 'location'));
    if (this.location) {
      pills.appendChild(document.createTextNode(' › '));
      pills.appendChild(make('Zone', this.zone?.name, 'zone'));
    }
    if (this.zone) {
      pills.appendChild(document.createTextNode(' › '));
      pills.appendChild(make('Container', this.container?.name, 'container'));
    }
  }

  async _openDropdown(level) {
    const dd = this.el.querySelector('#lp-dropdown');
    dd.style.display = 'block';
    dd.innerHTML = `<div class="loc-dd-inner"><input class="loc-search-input" placeholder="Search…" autocomplete="off"><div class="loc-dd-list"><div style="padding:12px;color:var(--text-3);font-size:14px">Loading…</div></div></div>`;

    const input = dd.querySelector('.loc-search-input');
    const list = dd.querySelector('.loc-dd-list');

    let items = [];
    if (level === 'location') {
      items = await api.getLocations();
    } else if (level === 'zone') {
      items = await api.getZones(this.location.id);
      // prepend "No zone" option
      items = [{ id: null, name: '— No zone' }, ...items];
    } else if (level === 'container') {
      const params = {};
      if (this.zone) params.zone_id = this.zone.id;
      else if (this.location) params.location_id = this.location.id;
      items = await api.getContainers(params);
      items = [{ id: null, name: '— No container' }, ...items];
    }

    const render = (filter = '') => {
      const filtered = filter
        ? items.filter(i => i.name.toLowerCase().includes(filter.toLowerCase()))
        : items;
      list.innerHTML = filtered.length ? '' : `<div style="padding:12px;color:var(--text-3);font-size:14px">No results</div>`;
      filtered.forEach(item => {
        const row = document.createElement('div');
        row.className = 'loc-dd-row';
        const isCurrent =
          (level === 'location' && this.location?.id === item.id) ||
          (level === 'zone' && this.zone?.id === item.id) ||
          (level === 'container' && this.container?.id === item.id);
        if (isCurrent) row.classList.add('current');
        row.textContent = item.name;
        row.onclick = () => {
          if (level === 'location') {
            this.location = item.id ? item : null;
            this.zone = null;
            this.container = null;
          } else if (level === 'zone') {
            this.zone = item.id ? item : null;
            this.container = null;
          } else {
            this.container = item.id ? item : null;
          }
          dd.style.display = 'none';
          this._renderPills();
          this.onChange?.(this.location, this.zone, this.container);
        };
        list.appendChild(row);
      });
    };

    render();
    input.addEventListener('input', () => render(input.value));
    setTimeout(() => input.focus(), 50);

    // close on outside click
    const close = (e) => {
      if (!dd.contains(e.target) && !this.el.querySelector('#lp-pills').contains(e.target)) {
        dd.style.display = 'none';
        document.removeEventListener('click', close);
      }
    };
    setTimeout(() => document.addEventListener('click', close), 100);
  }
}

// ── FORMS ─────────────────────────────────────────────────────────────────────

function showContainerForm(location, zone = null, container = null, onDone = null) {
  const isEdit = !!container;
  const types = ['box', 'bag', 'drawer', 'shelf', 'rack', 'bin', 'other'];

  const { el, close } = createModal({
    title: isEdit ? 'Edit Container' : 'New Container',
    body: `
      <div class="form-group">
        <label class="form-label">Name</label>
        <input class="form-input" id="con-name" value="${container?.name || ''}" placeholder="e.g. Blue Bin">
      </div>
      <div class="form-group">
        <label class="form-label">Notes</label>
        <textarea class="form-input" id="con-notes" placeholder="Optional description">${container?.notes || ''}</textarea>
      </div>
      <div class="form-group">
        <label class="form-label">Type</label>
        <select class="form-input" id="con-type">
          ${types.map(t => `<option value="${t}" ${(container?.type || 'box') === t ? 'selected' : ''}>${t}</option>`).join('')}
        </select>
      </div>
      ${isEdit ? `
      <div class="form-group">
        <label class="form-label">Location</label>
        <div id="con-loc-picker"></div>
      </div>` : ''}
      <div class="form-group">
        <label class="form-label">Photo</label>
        <div id="con-photo-wrap"></div>
      </div>`,
    footer: `<button class="btn btn-primary" style="width:100%" id="con-save">${isEdit ? 'Save' : 'Add Container'}</button>`,
  });

  const photoWidget = new PhotoWidget(el.querySelector('#con-photo-wrap'), container?.photo || null);

  let pickedLocation = location;
  let pickedZone = zone;

  if (isEdit) {
    new LocationPicker(
      el.querySelector('#con-loc-picker'),
      { location, zone },
      (loc, z) => { pickedLocation = loc; pickedZone = z; }
    );
  }

  el.querySelector('#con-save').onclick = async () => {
    const name = el.querySelector('#con-name').value.trim();
    if (!name) return;
    const payload = {
      name,
      notes: el.querySelector('#con-notes').value.trim(),
      type: el.querySelector('#con-type').value,
    };
    const photoPay = photoWidget.getPayload();
    if (photoPay !== undefined) payload.photo = photoPay;

    if (isEdit) {
      payload.location_id = pickedLocation?.id || null;
      payload.zone_id = pickedZone?.id || null;
      await api.updateContainer(container.id, payload);
      showToast('Container updated');
    } else {
      payload.location_id = location.id;
      if (zone) payload.zone_id = zone.id;
      await api.createContainer(payload);
      showToast('Container added');
    }
    close();
    onDone ? onDone() : refreshCurrentView();
  };
}

function showItemForm(container, item = null, onDone) {
  const isEdit = !!item;
  const { el, close } = createModal({
    title: isEdit ? 'Edit Item' : 'New Item',
    body: `
      <div class="form-group">
        <label class="form-label">Name</label>
        <input class="form-input" id="item-name" value="${item?.name || ''}" placeholder="Item name">
      </div>
      <div class="form-group">
        <label class="form-label">Quantity</label>
        <div class="qty-stepper">
          <button id="qty-minus">−</button>
          <span id="qty-val">${item?.quantity ?? ''}</span>
          <button id="qty-plus">+</button>
          <button class="btn btn-sm btn-secondary" id="qty-clear" style="margin-left:8px">None</button>
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">Notes</label>
        <textarea class="form-input" id="item-notes" placeholder="Optional — alphanumeric and emojis 📦">${item?.notes || ''}</textarea>
      </div>
      <div class="form-group">
        <label class="form-label">Tags <span style="color:var(--text-3);font-weight:400">(space or Enter to add)</span></label>
        <div id="item-tags-wrap"></div>
      </div>
      ${isEdit ? `
      <div class="form-group">
        <label class="form-label">Location</label>
        <div id="item-loc-picker"></div>
      </div>` : ''}
      <div class="form-group">
        <label class="form-label">Photo</label>
        <div id="item-photo-wrap"></div>
      </div>`,
    footer: `<button class="btn btn-primary" style="width:100%" id="item-save">${isEdit ? 'Save' : 'Add Item'}</button>`,
  });

  const photoWidget = new PhotoWidget(el.querySelector('#item-photo-wrap'), item?.photo || null);
  const tagInput = new TagInput(el.querySelector('#item-tags-wrap'), item?.tags || []);

  // Location picker — edit mode only
  // We need to reconstruct current location/zone/container from the item view data
  let pickedLocation = null;
  let pickedZone = null;
  let pickedContainer = container;

  if (isEdit && el.querySelector('#item-loc-picker')) {
    // Pull current location context from the stack
    const stackItem = state.stack.find(s => s.type === 'item');
    const initLoc = stackItem?.data?.location || null;
    const initZone = stackItem?.data?.zone || null;
    const initContainer = stackItem?.data?.container || null;
    pickedLocation = initLoc;
    pickedZone = initZone;
    pickedContainer = initContainer;

    new LocationPicker(
      el.querySelector('#item-loc-picker'),
      { location: initLoc, zone: initZone, container: initContainer },
      (loc, z, con) => {
        pickedLocation = loc;
        pickedZone = z;
        pickedContainer = con;
      }
    );
  }

  let qty = item?.quantity ?? null;
  const qtyVal = el.querySelector('#qty-val');
  const updateQty = () => { qtyVal.textContent = qty === null ? '' : qty; };
  el.querySelector('#qty-minus').onclick = () => { if (qty===null) qty=0; qty=Math.max(0,qty-1); updateQty(); };
  el.querySelector('#qty-plus').onclick = () => { if (qty===null) qty=0; qty++; updateQty(); };
  el.querySelector('#qty-clear').onclick = () => { qty=null; updateQty(); };

  el.querySelector('#item-save').onclick = async () => {
    const name = el.querySelector('#item-name').value.trim();
    if (!name) return;
    const payload = {
      name, quantity: qty,
      notes: el.querySelector('#item-notes').value.trim(),
      tags: tagInput.getValue(),
    };
    const photoPay = photoWidget.getPayload();
    if (photoPay !== undefined) payload.photo = photoPay;

    if (isEdit) {
      payload.location_id = pickedLocation?.id || null;
      payload.zone_id = pickedZone?.id || null;
      payload.container_id = pickedContainer?.id || null;
      await api.updateItem(item.id, payload);
      showToast('Item updated');
    } else {
      payload.container_id = container?.id || null;
      payload.location_id = container?.location_id || null;
      payload.zone_id = container?.zone_id || null;
      await api.createItem(payload);
      showToast('Item added');
    }
    close();
    onDone?.();
  };

  setTimeout(() => el.querySelector('#item-name').focus(), 100);
}


// ── Action menus ──────────────────────────────────────────────────────────────

function showAddInLocationMenu(location) {
  const { el, close } = createModal({
    title: 'Add to ' + location.name,
    body: `
      <div class="card" style="margin:0">
        <div class="action-row" id="add-zone">${IC.zone}<span>New Zone</span></div>
        <div class="action-row" id="add-container">${IC.box}<span>New Container (no zone)</span></div>
        <div class="action-row" id="add-item">${IC.item}<span>New Item (no zone, no container)</span></div>
      </div>`,
  });
  el.querySelector('#add-zone').onclick = () => { close(); showZoneForm(location); };
  el.querySelector('#add-container').onclick = () => { close(); showContainerForm(location, null, null, () => refreshCurrentView()); };
  el.querySelector('#add-item').onclick = () => {
    close();
    showLooseItemForm({ location_id: location.id }, () => refreshCurrentView());
  };
}

function showAddInZoneMenu(zone) {
  const { el, close } = createModal({
    title: 'Add to ' + zone.name,
    body: `
      <div class="card" style="margin:0">
        <div class="action-row" id="add-container">${IC.box}<span>New Container</span></div>
        <div class="action-row" id="add-item">${IC.item}<span>New Item (no container)</span></div>
      </div>`,
  });
  el.querySelector('#add-container').onclick = () => { close(); showContainerForm(zone.location, zone, null, () => refreshCurrentView()); };
  el.querySelector('#add-item').onclick = () => {
    close();
    showLooseItemForm({ location_id: zone.location?.id, zone_id: zone.id }, () => refreshCurrentView());
  };
}

function showLooseItemForm(parentIds, onDone) {
  const { el, close } = createModal({
    title: 'New Item',
    body: `
      <div class="form-group">
        <label class="form-label">Name</label>
        <input class="form-input" id="item-name" placeholder="Item name">
      </div>
      <div class="form-group">
        <label class="form-label">Quantity</label>
        <div class="qty-stepper">
          <button id="qty-minus">−</button>
          <span id="qty-val"></span>
          <button id="qty-plus">+</button>
          <button class="btn btn-sm btn-secondary" id="qty-clear" style="margin-left:8px">None</button>
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">Notes</label>
        <textarea class="form-input" id="item-notes" placeholder="Optional"></textarea>
      </div>
      <div class="form-group">
        <label class="form-label">Photo</label>
        <div id="item-photo-wrap"></div>
      </div>`,
    footer: `<button class="btn btn-primary" style="width:100%" id="item-save">Add Item</button>`,
  });

  const photoWidget = new PhotoWidget(el.querySelector('#item-photo-wrap'));
  let qty = null;
  const qtyVal = el.querySelector('#qty-val');
  el.querySelector('#qty-minus').onclick = () => { if (qty===null) qty=0; qty=Math.max(0,qty-1); qtyVal.textContent=qty; };
  el.querySelector('#qty-plus').onclick = () => { if (qty===null) qty=0; qty++; qtyVal.textContent=qty; };
  el.querySelector('#qty-clear').onclick = () => { qty=null; qtyVal.textContent=''; };

  el.querySelector('#item-save').onclick = async () => {
    const name = el.querySelector('#item-name').value.trim();
    if (!name) return;
    const payload = { name, quantity: qty, notes: el.querySelector('#item-notes').value.trim(), ...parentIds };
    const photoPay = photoWidget.getPayload();
    if (photoPay !== undefined) payload.photo = photoPay;
    await api.createItem(payload);
    showToast('Item added'); close(); onDone?.();
  };
  setTimeout(() => el.querySelector('#item-name').focus(), 100);
}

function showLocationActions(loc) {
  const { el, close } = createModal({
    title: loc.name,
    body: `
      <div class="card" style="margin:0">
        <div class="action-row" id="edit-loc">${IC.edit}<span>Edit</span></div>
        <div class="action-row danger" id="del-loc">${IC.trash}<span>Delete</span></div>
      </div>`,
  });
  el.querySelector('#edit-loc').onclick = () => { close(); showLocationForm(loc); };
  el.querySelector('#del-loc').onclick = async () => {
    close();
    const ok = await showConfirm({ title: `Delete "${loc.name}"?`, message: 'This will delete all zones, containers and items inside.' });
    if (!ok) return;
    await api.deleteLocation(loc.id);
    showToast('Location deleted');
    render();
  };
}

function showZoneActions(zone, location, contentEl) {
  const { el, close } = createModal({
    title: zone.name,
    body: `
      <div class="card" style="margin:0">
        <div class="action-row" id="edit-z">${IC.edit}<span>Edit</span></div>
        <div class="action-row danger" id="del-z">${IC.trash}<span>Delete</span></div>
      </div>`,
  });
  el.querySelector('#edit-z').onclick = () => { close(); showZoneForm(location, zone); };
  el.querySelector('#del-z').onclick = async () => {
    close();
    const ok = await showConfirm({ title: `Delete "${zone.name}"?`, message: 'This will delete all containers and items inside.' });
    if (!ok) return;
    await api.deleteZone(zone.id);
    showToast('Zone deleted');
    refreshCurrentView();
  };
}

function showContainerActions(container, location, zone) {
  const { el, close } = createModal({
    title: container.name,
    body: `
      <div class="card" style="margin:0">
        <div class="action-row" id="edit-c">${IC.edit}<span>Edit</span></div>
        <div class="action-row danger" id="del-c">${IC.trash}<span>Delete</span></div>
      </div>`,
  });
  el.querySelector('#edit-c').onclick = () => { close(); showContainerForm(location, zone, container, () => refreshCurrentView()); };
  el.querySelector('#del-c').onclick = async () => {
    close();
    const ok = await showConfirm({ title: `Delete "${container.name}"?`, message: 'This will delete all items inside.' });
    if (!ok) return;
    await api.deleteContainer(container.id);
    showToast('Container deleted');
    refreshCurrentView();
  };
}

function showItemActions(item, onRefresh) {
  const { el, close } = createModal({
    title: item.name,
    body: `
      <div class="card" style="margin:0">
        <div class="action-row" id="edit-i">${IC.edit}<span>Edit</span></div>
        <div class="action-row danger" id="del-i">${IC.trash}<span>Delete</span></div>
      </div>`,
  });
  el.querySelector('#edit-i').onclick = () => { close(); showItemForm(null, item, onRefresh); };
  el.querySelector('#del-i').onclick = async () => {
    close();
    const ok = await showConfirm({ title: `Delete "${item.name}"?` });
    if (!ok) return;
    await api.deleteItem(item.id);
    showToast('Item deleted');
    onRefresh?.();
  };
}

// ── Refresh current view ──────────────────────────────────────────────────────
function refreshCurrentView() {
  render();
}

// ── Long press ────────────────────────────────────────────────────────────────
function addLongPress(el, callback) {
  let timer;
  el.addEventListener('touchstart', () => { timer = setTimeout(callback, 500); }, { passive: true });
  el.addEventListener('touchend', () => clearTimeout(timer), { passive: true });
  el.addEventListener('touchmove', () => clearTimeout(timer), { passive: true });
}

// ── Export / Import ───────────────────────────────────────────────────────────
async function doExport() {
  const blob = await api.exportData();
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url; a.download = 'onecastle-export.json'; a.click();
  URL.revokeObjectURL(url);
  showToast('Exported');
}

function doImport() {
  const input = document.createElement('input');
  input.type = 'file'; input.accept = '.json,application/json';
  input.onchange = async () => {
    const file = input.files[0]; if (!file) return;
    const text = await file.text();
    const data = JSON.parse(text);
    await api.importData(data);
    showToast('Imported successfully');
    render();
  };
  input.click();
}

// ── Init ──────────────────────────────────────────────────────────────────────
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => navigator.serviceWorker.register('/sw.js'));
}

window.addEventListener('DOMContentLoaded', render);
