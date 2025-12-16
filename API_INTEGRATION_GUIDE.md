# راهنمای API اپلیکیشن نانوایی

## راه‌اندازی سرور

```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

سرور در `http://localhost:3000` اجرا می‌شود.
پنل مدیریت: `http://localhost:3000/admin`

## ایجاد ادمین اولیه

```bash
curl -X POST http://localhost:3000/api/auth/create-admin \
  -H "Content-Type: application/json" \
  -d '{"phone": "09123456789", "name": "مدیر"}'
```

رمز عبور پیش‌فرض: `123456`

---

## API Endpoints

### 🔐 احراز هویت (`/api/auth`)

| Method | Endpoint | توضیحات |
|--------|----------|---------|
| POST | `/send-code` | ارسال کد تایید SMS |
| POST | `/verify` | تایید کد و دریافت توکن |
| GET | `/me` | دریافت اطلاعات کاربر |
| PUT | `/profile` | به‌روزرسانی پروفایل |
| POST | `/admin-login` | ورود ادمین |
| POST | `/create-admin` | ایجاد ادمین اولیه |

### 💼 آگهی‌های شغلی (`/api/job-ads`)

| Method | Endpoint | توضیحات |
|--------|----------|---------|
| GET | `/` | لیست آگهی‌ها |
| GET | `/:id` | جزئیات آگهی |
| POST | `/` | ایجاد آگهی (نیاز به توکن) |
| PUT | `/:id` | ویرایش آگهی |
| DELETE | `/:id` | حذف آگهی |
| GET | `/my` | آگهی‌های من |

### 🔍 کارجویان (`/api/job-seekers`)

| Method | Endpoint | توضیحات |
|--------|----------|---------|
| GET | `/` | لیست کارجویان |
| GET | `/:id` | جزئیات کارجو |
| POST | `/` | ثبت رزومه |
| PUT | `/:id` | ویرایش رزومه |
| DELETE | `/:id` | حذف رزومه |

### 🏪 آگهی‌های نانوایی (`/api/bakery-ads`)

| Method | Endpoint | توضیحات |
|--------|----------|---------|
| GET | `/` | لیست آگهی‌ها (فروش/اجاره) |
| GET | `/:id` | جزئیات آگهی |
| POST | `/` | ایجاد آگهی |
| PUT | `/:id` | ویرایش آگهی |
| DELETE | `/:id` | حذف آگهی |

### ⚙️ تجهیزات (`/api/equipment-ads`)

| Method | Endpoint | توضیحات |
|--------|----------|---------|
| GET | `/` | لیست تجهیزات |
| GET | `/:id` | جزئیات تجهیزات |
| POST | `/` | ایجاد آگهی |
| PUT | `/:id` | ویرایش آگهی |
| DELETE | `/:id` | حذف آگهی |

### 💬 چت (`/api/chat`)

| Method | Endpoint | توضیحات |
|--------|----------|---------|
| GET | `/conversations` | لیست مکالمات |
| GET | `/messages/:recipientId` | پیام‌های یک مکالمه |
| POST | `/send` | ارسال پیام |

### 🔔 نوتیفیکیشن (`/api/notifications`)

| Method | Endpoint | توضیحات |
|--------|----------|---------|
| GET | `/` | لیست نوتیفیکیشن‌ها |
| PUT | `/:id/read` | علامت خوانده شده |
| PUT | `/read-all` | همه خوانده شدند |
| DELETE | `/:id` | حذف نوتیفیکیشن |

### ⭐ نظرات (`/api/reviews`)

| Method | Endpoint | توضیحات |
|--------|----------|---------|
| GET | `/:targetType/:targetId` | نظرات یک آگهی |
| POST | `/` | ثبت نظر |
| DELETE | `/:id` | حذف نظر |

### 📤 آپلود (`/api/upload`)

| Method | Endpoint | توضیحات |
|--------|----------|---------|
| POST | `/image` | آپلود تک عکس |
| POST | `/images` | آپلود چند عکس |
| POST | `/video` | آپلود ویدیو |
| DELETE | `/:type/:filename` | حذف فایل |

### 📊 آمار (`/api/statistics`)

| Method | Endpoint | توضیحات |
|--------|----------|---------|
| GET | `/` | آمار عمومی |
| GET | `/admin` | آمار کامل (ادمین) |
| GET | `/charts` | داده نمودار |

---

## نمونه درخواست‌ها

### ورود با کد تایید
```javascript
// ارسال کد
const res1 = await fetch('/api/auth/send-code', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ phone: '09123456789' })
});

// تایید کد
const res2 = await fetch('/api/auth/verify', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ phone: '09123456789', code: '1234' })
});
const { token } = await res2.json();
```

### آپلود عکس
```javascript
const formData = new FormData();
formData.append('image', file);

const res = await fetch('/api/upload/image', {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${token}` },
  body: formData
});
const { data } = await res.json();
// data.url = '/uploads/images/xxx.jpg'
```

### ایجاد آگهی شغلی
```javascript
const res = await fetch('/api/job-ads', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    title: 'نانوای ماهر',
    category: 'نانوا',
    salary: 15000000,
    location: 'تهران',
    description: 'نیازمند نانوای با تجربه',
    images: ['/uploads/images/xxx.jpg']
  })
});
```

---

## پنل مدیریت

آدرس: `http://localhost:3000/admin`

### امکانات:
- 📊 داشبورد با آمار کلی
- 👥 مدیریت کاربران
- 💼 مدیریت آگهی‌های شغلی (تایید/رد)
- 🔍 مدیریت کارجویان
- 🏪 مدیریت آگهی‌های نانوایی
- ⚙️ مدیریت تجهیزات
- ⭐ مدیریت نظرات
- 🔔 ارسال نوتیفیکیشن به کاربران

---

## ساختار پوشه‌ها

```
backend/
├── middleware/
│   ├── auth.js          # احراز هویت JWT
│   └── upload.js        # آپلود فایل
├── models/
│   ├── User.js
│   ├── JobAd.js
│   ├── JobSeeker.js
│   ├── BakeryAd.js
│   ├── EquipmentAd.js
│   ├── Review.js
│   ├── Chat.js
│   └── Notification.js
├── routes/
│   ├── auth.js
│   ├── jobAds.js
│   ├── jobSeekers.js
│   ├── bakeryAds.js
│   ├── equipmentAds.js
│   ├── reviews.js
│   ├── chat.js
│   ├── notifications.js
│   ├── upload.js
│   ├── admin.js
│   ├── statistics.js
│   └── users.js
├── public/admin/        # پنل مدیریت
├── uploads/             # فایل‌های آپلود شده
│   ├── images/
│   └── videos/
├── server.js
├── package.json
└── .env.example
```
