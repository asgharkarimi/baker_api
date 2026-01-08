-- =============================================
-- اضافه کردن Index برای بهبود سرعت query ها
-- این فایل رو روی دیتابیس سرور اجرا کن
-- =============================================

-- Index برای bakery_ads
ALTER TABLE bakery_ads ADD INDEX idx_bakery_status (is_active, is_approved);
ALTER TABLE bakery_ads ADD INDEX idx_bakery_type (type);
ALTER TABLE bakery_ads ADD INDEX idx_bakery_created (created_at);

-- Index برای equipment_ads  
ALTER TABLE equipment_ads ADD INDEX idx_equipment_status (is_active, is_approved);
ALTER TABLE equipment_ads ADD INDEX idx_equipment_condition (`condition`);
ALTER TABLE equipment_ads ADD INDEX idx_equipment_created (created_at);

-- Index برای job_ads
ALTER TABLE job_ads ADD INDEX idx_job_created (created_at);

-- Index برای job_seekers
ALTER TABLE job_seekers ADD INDEX idx_seeker_status (is_active, is_approved);
ALTER TABLE job_seekers ADD INDEX idx_seeker_created (created_at);

-- Index برای chats (پیام‌ها)
ALTER TABLE chats ADD INDEX idx_chat_created (created_at);

-- بررسی Index های موجود
SHOW INDEX FROM bakery_ads;
SHOW INDEX FROM equipment_ads;
SHOW INDEX FROM job_ads;
SHOW INDEX FROM job_seekers;
