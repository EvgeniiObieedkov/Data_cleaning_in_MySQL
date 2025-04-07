-- Switch to the working database
USE nashville_housing_db;

-- 1. Add a new column to store the sale date in DATE format
ALTER TABLE property_sales
ADD COLUMN SaleDateConverted DATE;

-- Convert the existing SaleDate to DATE-only format
UPDATE property_sales
SET SaleDateConverted = DATE(SaleDate);

-- 2. Fill in missing PropertyAddress values using matching ParcelID from other rows
-- Assumes same ParcelID always has the same address
UPDATE property_sales a
JOIN property_sales b
  ON a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
 AND b.PropertyAddress IS NOT NULL
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL;

-- 3. Split PropertyAddress into separate columns: street address and city
ALTER TABLE property_sales
ADD COLUMN PropertySplitAddress VARCHAR(255),
ADD COLUMN PropertySplitCity VARCHAR(255);

-- Extract street (before comma) and city (after comma)
UPDATE property_sales
SET PropertySplitAddress = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', 1)),
    PropertySplitCity = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1))
WHERE PropertyAddress IS NOT NULL;

-- 4. Split OwnerAddress into separate columns: address, city, and state
ALTER TABLE property_sales
ADD COLUMN OwnerSplitAddress VARCHAR(255),
ADD COLUMN OwnerSplitCity VARCHAR(255),
ADD COLUMN OwnerSplitState VARCHAR(255);

-- Parse OwnerAddress into components using nested SUBSTRING_INDEX
UPDATE property_sales
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)),
    OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)),
    OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1))
WHERE OwnerAddress IS NOT NULL;

-- 5. Normalize 'SoldAsVacant' values to 'Yes' and 'No'
UPDATE property_sales
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

-- 6. Remove duplicate rows, keeping the one with the lowest UniqueID
-- Create temporary table with duplicate UniqueIDs to delete
CREATE TEMPORARY TABLE tmp_duplicates AS
SELECT UniqueID
FROM (
    SELECT UniqueID,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDateConverted, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM property_sales
) AS numbered
WHERE row_num > 1;

-- Delete duplicates using UniqueID from temp table
DELETE FROM property_sales
WHERE UniqueID IN (SELECT UniqueID FROM tmp_duplicates);

-- Drop temporary table (optional; it's session-scoped)
DROP TEMPORARY TABLE IF EXISTS tmp_duplicates;

-- 7. Drop original columns that are no longer needed
ALTER TABLE property_sales
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;


select *
from property_sales

