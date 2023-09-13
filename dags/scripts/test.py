from extraction_pokemon import extraction_dummy_tables, extraction_script

for table in extraction_dummy_tables.TABLES:
    extraction_script.table_processing(table)