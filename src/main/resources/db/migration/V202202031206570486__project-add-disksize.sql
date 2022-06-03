-- Add project size/disk usage to Project table
ALTER TABLE project ADD size_in_bytes BIGINT NOT NULL DEFAULT '0';