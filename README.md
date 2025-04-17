### Nashville Housing Data — End-to-End SQL and Python Project

#### Project Type  
Full data pipeline project combining **Python (Pandas)** for data ingestion and **SQL (MySQL)** for data cleaning and transformation.

#### Goal  
To import raw real estate data from Excel into a MySQL database, clean and transform it for analysis.

#### Process  

1. **Data Import (Python)**  
   - Loaded Excel data into a Pandas dictionary using `pd.ExcelFile`.
   - Cleaned column names.
   - Created the MySQL database `nashville_housing_db` using `mysql.connector`.
   - Uploaded data into MySQL using SQLAlchemy and `to_sql()`.

2. **Data Cleaning (SQL)**  
   - Converted datetime columns to date format.
   - Filled missing property addresses using self-joins.
   - Split `PropertyAddress` and `OwnerAddress` into separate components.
   - Normalized values in the `SoldAsVacant` column.
   - Removed duplicate records using `ROW_NUMBER()` and a temporary table.
   - Dropped redundant columns.

#### Insights  
- Address and ownership data required parsing and normalization.  
- More than 30,000 entries had missing or partial values that were cleaned.  
- Final dataset is clean, well-structured, and ready for analysis or visualization.
