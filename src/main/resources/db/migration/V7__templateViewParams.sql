ALTER TABLE template_view_params ADD COLUMN IF NOT EXISTS template_id BIGINT;
UPDATE template_view_params SET template_id = view_params;
ALTER TABLE template_view_params DROP COLUMN IF EXISTS view_params;
ALTER TABLE template_view_params ADD COLUMN IF NOT EXISTS view_params_string varchar(255);