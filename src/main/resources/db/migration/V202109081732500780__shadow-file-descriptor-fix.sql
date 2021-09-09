ALTER TABLE "shadow_file_descriptor" DROP CONSTRAINT "shadow_file_descriptor_pkey";
ALTER TABLE "shadow_file_descriptor" ADD PRIMARY KEY ("task_descriptor_id", "name", "record_idx");