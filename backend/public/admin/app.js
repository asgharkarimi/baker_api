const API_URL = '/api';
let token = localStorage.getItem('adminToken');
let currentPage = 'dashboard';

// DOM Elements
const loginPage = document.getElementById('loginPage');
const adminPanel = document.getElementById('adminPanel');
const loginForm = document.getElementById('loginForm');
const loginError = document.getElementById('loginError');
const logoutBtn = document.getElementById('logoutBtn');
const modal = document.getElementById('modal');
const modalBody = document.getElementById('modalBody');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
  if (token) {
    showAdminPanel();
  }
  setupEventListeners();
});

function setupEventListeners() {
  loginForm.addEventListener('submit', handleLogin);
  logoutBtn.addEventListener('click', handleLogout);
  
  document.querySelectorAll('.sidebar nav a').forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      const page = e.target.dataset.page;
      navigateTo(page);
    });
  });

  document.querySelector('.close-btn').addEventListener('click', closeModal);
  modal.addEventListener('click', (e) => {
    if (e.target === modal) closeModal();
  });

  // Search & Filter listeners
  document.getElementById('userSearch')?.addEventListener('input', debounce(() => loadUsers(), 500));
  document.getElementById('userRoleFilter')?.addEventListener('change', () => loadUsers());
  document.getElementById('jobAdSearch')?.addEventListener('input', debounce(() => loadJobAds(), 500));
  document.getElementById('jobAdApproved')?.addEventListener('change', () => loadJobAds());
  document.getElementById('notificationForm')?.addEventListener('submit', handleSendNotification);
}

// Auth
async function handleLogin(e) {
  e.preventDefault();
  const phone = document.getElementById('loginPhone').value;
  const password = document.getElementById('loginPassword').value;

  try {
    const res = await fetch(`${API_URL}/auth/admin-login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phone, password })
    });
    const data = await res.json();
    
    if (data.success) {
      token = data.token;
      localStorage.setItem('adminToken', token);
      showAdminPanel();
    } else {
      loginError.textContent = data.message || 'خطا در ورود';
    }
  } catch (err) {
    loginError.textContent = 'خطا در اتصال به سرور';
  }
}

function handleLogout() {
  token = null;
  localStorage.removeItem('adminToken');
  adminPanel.classList.add('hidden');
  loginPage.classList.remove('hidden');
}

function showAdminPanel() {
  loginPage.classList.add('hidden');
  adminPanel.classList.remove('hidden');
  navigateTo('dashboard');
}

// Navigation
function navigateTo(page) {
  currentPage = page;
  document.querySelectorAll('.page').forEach(p => p.classList.add('hidden'));
  document.getElementById(`${page}Page`).classList.remove('hidden');
  document.querySelectorAll('.sidebar nav a').forEach(a => a.classList.remove('active'));
  document.querySelector(`[data-page="${page}"]`).classList.add('active');

  switch(page) {
    case 'dashboard': loadDashboard(); break;
    case 'users': loadUsers(); break;
    case 'jobAds': loadJobAds(); break;
    case 'jobSeekers': loadJobSeekers(); break;
    case 'bakeryAds': loadBakeryAds(); break;
    case 'equipmentAds': loadEquipmentAds(); break;
    case 'reviews': loadReviews(); break;
    case 'notifications': loadUsersForNotification(); break;
  }
}

// API Helper
async function apiCall(endpoint, method = 'GET', body = null) {
  const options = {
    method,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    }
  };
  if (body) options.body = JSON.stringify(body);
  
  const res = await fetch(`${API_URL}${endpoint}`, options);
  return res.json();
}

// Dashboard
async function loadDashboard() {
  try {
    const data = await apiCall('/admin/dashboard');
    if (data.success) {
      const { counts, pending, onlineUsers, today, weeklyStats, locationStats, recentUsers, recentJobAds } = data.data;
      
      // آمار کلی
      document.getElementById('statsGrid').innerHTML = `
        <div class="stat-card"><div class="icon">👥</div><div class="value">${counts.users}</div><div class="label">کاربران</div></div>
        <div class="stat-card"><div class="icon">💼</div><div class="value">${counts.jobAds}</div><div class="label">آگهی شغلی</div></div>
        <div class="stat-card"><div class="icon">🔍</div><div class="value">${counts.jobSeekers}</div><div class="label">کارجو</div></div>
        <div class="stat-card"><div class="icon">🏪</div><div class="value">${counts.bakeryAds}</div><div class="label">آگهی نانوایی</div></div>
        <div class="stat-card"><div class="icon">⚙️</div><div class="value">${counts.equipmentAds}</div><div class="label">تجهیزات</div></div>
        <div class="stat-card"><div class="icon">💬</div><div class="value">${counts.chats}</div><div class="label">پیام‌ها</div></div>
        <div class="stat-card"><div class="icon">🟢</div><div class="value">${onlineUsers}</div><div class="label">آنلاین</div></div>
      `;
      
      // در انتظار تایید
      document.getElementById('pendingStats').innerHTML = `
        <div class="pending-card"><div class="value">${pending.jobAds}</div><div class="label">آگهی شغلی</div></div>
        <div class="pending-card"><div class="value">${pending.jobSeekers}</div><div class="label">کارجو</div></div>
      `;
      
      // آمار امروز
      document.getElementById('todayStats').innerHTML = `
        <div class="today-card"><div class="value">${today.users}</div><div class="label">کاربر جدید</div></div>
        <div class="today-card"><div class="value">${today.jobAds}</div><div class="label">آگهی شغلی</div></div>
        <div class="today-card"><div class="value">${today.jobSeekers}</div><div class="label">کارجو</div></div>
        <div class="today-card"><div class="value">${today.chats}</div><div class="label">پیام</div></div>
      `;
      
      // نمودار هفتگی
      const maxVal = Math.max(...weeklyStats.flatMap(s => [s.users, s.jobAds, s.jobSeekers]), 1);
      document.getElementById('weeklyChart').innerHTML = `
        <div class="chart-bars">
          ${weeklyStats.map(s => `
            <div class="chart-bar">
              <div class="bar-group">
                <div class="bar bar-users" style="height: ${(s.users / maxVal) * 120}px" title="کاربر: ${s.users}"></div>
                <div class="bar bar-jobs" style="height: ${(s.jobAds / maxVal) * 120}px" title="آگهی: ${s.jobAds}"></div>
                <div class="bar bar-seekers" style="height: ${(s.jobSeekers / maxVal) * 120}px" title="کارجو: ${s.jobSeekers}"></div>
              </div>
              <div class="bar-label">${s.date}</div>
            </div>
          `).join('')}
        </div>
        <div class="chart-legend">
          <div class="legend-item"><div class="legend-color bar-users"></div>کاربران</div>
          <div class="legend-item"><div class="legend-color bar-jobs"></div>آگهی‌ها</div>
          <div class="legend-item"><div class="legend-color bar-seekers"></div>کارجوها</div>
        </div>
      `;
      
      // آمار استان‌ها
      document.getElementById('locationStats').innerHTML = locationStats.length > 0 
        ? locationStats.map(l => `
            <div class="location-card">
              <span class="name">${l.location || 'نامشخص'}</span>
              <span class="count">${l.count}</span>
            </div>
          `).join('')
        : '<p style="color:#999">هنوز آگهی ثبت نشده</p>';
      
      // آخرین کاربران
      document.getElementById('recentUsers').innerHTML = recentUsers.length > 0
        ? recentUsers.map(u => `
            <div class="recent-item">
              <div class="info">
                <span class="name">${u.name || 'بدون نام'}</span>
                <span class="sub">${u.phone}</span>
              </div>
              <span class="time">${new Date(u.createdAt).toLocaleDateString('fa-IR')}</span>
            </div>
          `).join('')
        : '<p style="color:#999">کاربری ثبت نشده</p>';
      
      // آخرین آگهی‌ها
      document.getElementById('recentJobAds').innerHTML = recentJobAds.length > 0
        ? recentJobAds.map(ad => `
            <div class="recent-item">
              <div class="info">
                <span class="name">${ad.title}</span>
                <span class="sub">${ad.user?.name || ad.user?.phone || '-'}</span>
              </div>
              <span class="time">${new Date(ad.createdAt).toLocaleDateString('fa-IR')}</span>
            </div>
          `).join('')
        : '<p style="color:#999">آگهی ثبت نشده</p>';
    }
  } catch (err) {
    console.error('Error loading dashboard:', err);
  }
}

// Users
async function loadUsers(page = 1) {
  const search = document.getElementById('userSearch').value;
  const role = document.getElementById('userRoleFilter').value;
  
  try {
    const data = await apiCall(`/admin/users?page=${page}&search=${search}&role=${role}`);
    if (data.success) {
      renderUsersTable(data.data);
      renderPagination('usersPagination', data.pages, page, loadUsers);
    }
  } catch (err) {
    console.error('Error loading users:', err);
  }
}

function renderUsersTable(users) {
  document.getElementById('usersTable').innerHTML = `
    <table>
      <thead><tr><th>نام</th><th>موبایل</th><th>نقش</th><th>وضعیت</th><th>عملیات</th></tr></thead>
      <tbody>
        ${users.map(u => `
          <tr>
            <td>${u.name || '-'}</td>
            <td>${u.phone}</td>
            <td><span class="badge ${u.role === 'admin' ? 'badge-info' : 'badge-success'}">${u.role === 'admin' ? 'ادمین' : 'کاربر'}</span></td>
            <td><span class="badge ${u.isActive ? 'badge-success' : 'badge-danger'}">${u.isActive ? 'فعال' : 'غیرفعال'}</span></td>
            <td>
              <button class="action-btn btn-edit" onclick="editUser('${u.id}')">ویرایش</button>
              <button class="action-btn btn-delete" onclick="deleteUser('${u.id}')">حذف</button>
            </td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  `;
}

async function editUser(id) {
  const role = prompt('نقش جدید (user/admin):');
  if (role && ['user', 'admin'].includes(role)) {
    await apiCall(`/admin/users/${id}`, 'PUT', { role });
    loadUsers();
  }
}

async function deleteUser(id) {
  if (confirm('آیا مطمئن هستید؟')) {
    await apiCall(`/admin/users/${id}`, 'DELETE');
    loadUsers();
  }
}

// Job Ads
async function loadJobAds(page = 1) {
  const search = document.getElementById('jobAdSearch')?.value || '';
  const isApproved = document.getElementById('jobAdApproved')?.value || '';
  
  try {
    let url = `/admin/job-ads?page=${page}&search=${search}`;
    if (isApproved) url += `&isApproved=${isApproved}`;
    console.log('Loading job ads from:', url);
    const data = await apiCall(url);
    console.log('Job ads response:', data);
    if (data.success) {
      renderJobAdsTable(data.data);
      renderPagination('jobAdsPagination', data.pages, page, loadJobAds);
    } else {
      console.error('API error:', data.message);
    }
  } catch (err) {
    console.error('Error loading job ads:', err);
  }
}

function renderJobAdsTable(ads) {
  console.log('Job Ads received:', ads);
  if (!ads || ads.length === 0) {
    document.getElementById('jobAdsTable').innerHTML = '<p style="text-align:center;padding:20px;">هیچ آگهی شغلی یافت نشد</p>';
    return;
  }
  document.getElementById('jobAdsTable').innerHTML = `
    <table>
      <thead><tr><th>عنوان</th><th>دسته‌بندی</th><th>حقوق</th><th>وضعیت</th><th>عملیات</th></tr></thead>
      <tbody>
        ${ads.map(ad => `
          <tr>
            <td>${ad.title}</td>
            <td>${ad.category || '-'}</td>
            <td>${ad.salary ? ad.salary.toLocaleString() + ' تومان' : '-'}</td>
            <td><span class="badge ${ad.isApproved ? 'badge-success' : 'badge-warning'}">${ad.isApproved ? 'تایید شده' : 'در انتظار'}</span></td>
            <td>
              ${!ad.isApproved ? `<button class="action-btn btn-approve" onclick="approveJobAd('${ad.id}')">تایید</button>` : ''}
              <button class="action-btn btn-delete" onclick="deleteJobAd('${ad.id}')">حذف</button>
            </td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  `;
}

async function approveJobAd(id) {
  await apiCall(`/admin/job-ads/${id}/approve`, 'PUT');
  loadJobAds();
}

async function deleteJobAd(id) {
  if (confirm('آیا مطمئن هستید؟')) {
    await apiCall(`/admin/job-ads/${id}`, 'DELETE');
    loadJobAds();
  }
}

// Job Seekers
async function loadJobSeekers(page = 1) {
  const search = document.getElementById('jobSeekerSearch')?.value || '';
  try {
    const data = await apiCall(`/admin/job-seekers?page=${page}&search=${search}`);
    if (data.success) {
      document.getElementById('jobSeekersTable').innerHTML = `
        <table>
          <thead><tr><th>نام</th><th>مهارت‌ها</th><th>حقوق درخواستی</th><th>وضعیت</th><th>عملیات</th></tr></thead>
          <tbody>
            ${data.data.map(s => `
              <tr>
                <td>${s.name || '-'}</td>
                <td>${(s.skills || []).join('، ')}</td>
                <td>${s.expectedSalary ? s.expectedSalary.toLocaleString() + ' تومان' : '-'}</td>
                <td><span class="badge ${s.isApproved ? 'badge-success' : 'badge-warning'}">${s.isApproved ? 'تایید شده' : 'در انتظار'}</span></td>
                <td>
                  ${!s.isApproved ? `<button class="action-btn btn-approve" onclick="approveJobSeeker('${s.id}')">تایید</button>` : ''}
                  <button class="action-btn btn-delete" onclick="deleteJobSeeker('${s.id}')">حذف</button>
                </td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      `;
      renderPagination('jobSeekersPagination', data.pages, page, loadJobSeekers);
    }
  } catch (err) { console.error(err); }
}

async function approveJobSeeker(id) {
  await apiCall(`/admin/job-seekers/${id}/approve`, 'PUT');
  loadJobSeekers();
}

async function deleteJobSeeker(id) {
  if (confirm('آیا مطمئن هستید؟')) {
    await apiCall(`/admin/job-seekers/${id}`, 'DELETE');
    loadJobSeekers();
  }
}

// Bakery Ads
async function loadBakeryAds(page = 1) {
  const search = document.getElementById('bakeryAdSearch')?.value || '';
  const type = document.getElementById('bakeryAdType')?.value || '';
  const isApproved = document.getElementById('bakeryAdApproved')?.value || '';
  try {
    let url = `/admin/bakery-ads?page=${page}&search=${search}&type=${type}`;
    if (isApproved) url += `&isApproved=${isApproved}`;
    const data = await apiCall(url);
    if (data.success) {
      document.getElementById('bakeryAdsTable').innerHTML = `
        <table>
          <thead><tr><th>عنوان</th><th>نوع</th><th>قیمت</th><th>وضعیت</th><th>عملیات</th></tr></thead>
          <tbody>
            ${data.data.map(ad => `
              <tr>
                <td>${ad.title}</td>
                <td>${ad.type === 'sale' ? 'فروش' : 'اجاره'}</td>
                <td>${ad.salePrice ? ad.salePrice.toLocaleString() + ' تومان' : (ad.rentDeposit ? ad.rentDeposit.toLocaleString() + ' رهن' : '-')}</td>
                <td><span class="badge ${ad.isApproved ? 'badge-success' : 'badge-warning'}">${ad.isApproved ? 'تایید شده' : 'در انتظار'}</span></td>
                <td>
                  ${!ad.isApproved ? `<button class="action-btn btn-approve" onclick="approveBakeryAd('${ad.id}')">تایید</button>` : ''}
                  <button class="action-btn btn-delete" onclick="deleteBakeryAd('${ad.id}')">حذف</button>
                </td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      `;
      renderPagination('bakeryAdsPagination', data.pages, page, loadBakeryAds);
    }
  } catch (err) { console.error(err); }
}

async function approveBakeryAd(id) {
  await apiCall(`/admin/bakery-ads/${id}/approve`, 'PUT');
  loadBakeryAds();
}

async function deleteBakeryAd(id) {
  if (confirm('آیا مطمئن هستید؟')) {
    await apiCall(`/admin/bakery-ads/${id}`, 'DELETE');
    loadBakeryAds();
  }
}

// Equipment Ads
async function loadEquipmentAds(page = 1) {
  const search = document.getElementById('equipmentAdSearch')?.value || '';
  try {
    const data = await apiCall(`/admin/equipment-ads?page=${page}&search=${search}`);
    if (data.success) {
      document.getElementById('equipmentAdsTable').innerHTML = `
        <table>
          <thead><tr><th>عنوان</th><th>وضعیت</th><th>قیمت</th><th>عملیات</th></tr></thead>
          <tbody>
            ${data.data.map(ad => `
              <tr>
                <td>${ad.title}</td>
                <td>${ad.condition === 'new' ? 'نو' : 'دست دوم'}</td>
                <td>${ad.price ? ad.price.toLocaleString() + ' تومان' : '-'}</td>
                <td><button class="action-btn btn-delete" onclick="deleteEquipmentAd('${ad.id}')">حذف</button></td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      `;
      renderPagination('equipmentAdsPagination', data.pages, page, loadEquipmentAds);
    }
  } catch (err) { console.error(err); }
}

async function deleteEquipmentAd(id) {
  if (confirm('آیا مطمئن هستید؟')) {
    await apiCall(`/admin/equipment-ads/${id}`, 'DELETE');
    loadEquipmentAds();
  }
}

// Reviews
async function loadReviews(page = 1) {
  const isApproved = document.getElementById('reviewApproved')?.value || '';
  try {
    const data = await apiCall(`/admin/reviews?page=${page}&isApproved=${isApproved}`);
    if (data.success) {
      document.getElementById('reviewsTable').innerHTML = `
        <table>
          <thead><tr><th>کاربر</th><th>امتیاز</th><th>متن</th><th>وضعیت</th><th>عملیات</th></tr></thead>
          <tbody>
            ${data.data.map(r => `
              <tr>
                <td>${r.userId?.name || '-'}</td>
                <td>${'⭐'.repeat(r.rating)}</td>
                <td>${r.comment?.substring(0, 50) || '-'}...</td>
                <td><span class="badge ${r.isApproved ? 'badge-success' : 'badge-warning'}">${r.isApproved ? 'تایید شده' : 'در انتظار'}</span></td>
                <td>
                  ${!r.isApproved ? `<button class="action-btn btn-approve" onclick="approveReview('${r.id}')">تایید</button>` : ''}
                  <button class="action-btn btn-delete" onclick="deleteReview('${r.id}')">حذف</button>
                </td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      `;
      renderPagination('reviewsPagination', data.pages, page, loadReviews);
    }
  } catch (err) { console.error(err); }
}

async function approveReview(id) {
  await apiCall(`/admin/reviews/${id}/approve`, 'PUT');
  loadReviews();
}

async function deleteReview(id) {
  if (confirm('آیا مطمئن هستید؟')) {
    await apiCall(`/admin/reviews/${id}`, 'DELETE');
    loadReviews();
  }
}

// Notifications
async function loadUsersForNotification() {
  try {
    const data = await apiCall('/admin/users?limit=100');
    if (data.success) {
      const select = document.getElementById('notifUserId');
      select.innerHTML = '<option value="all">همه کاربران</option>' +
        data.data.map(u => `<option value="${u.id}">${u.name || u.phone}</option>`).join('');
    }
  } catch (err) { console.error(err); }
}

async function handleSendNotification(e) {
  e.preventDefault();
  const userId = document.getElementById('notifUserId').value;
  const title = document.getElementById('notifTitle').value;
  const message = document.getElementById('notifMessage').value;
  const type = document.getElementById('notifType').value;

  try {
    const data = await apiCall('/admin/notifications/send', 'POST', { userId, title, message, type });
    if (data.success) {
      alert(data.message);
      document.getElementById('notificationForm').reset();
    }
  } catch (err) {
    alert('خطا در ارسال');
  }
}

// Helpers
function renderPagination(containerId, totalPages, currentPage, loadFn) {
  const container = document.getElementById(containerId);
  if (!container || totalPages <= 1) {
    if (container) container.innerHTML = '';
    return;
  }
  
  let html = '';
  for (let i = 1; i <= totalPages; i++) {
    html += `<button class="${i === currentPage ? 'active' : ''}" onclick="${loadFn.name}(${i})">${i}</button>`;
  }
  container.innerHTML = html;
}

function debounce(fn, delay) {
  let timeout;
  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => fn(...args), delay);
  };
}

function closeModal() {
  modal.classList.add('hidden');
}
