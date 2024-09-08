
-- 1 Populate ParceID address data to avoid NULLS
SELECT * FROM nashvillehousingdatafordatacleaningcsv nash order by ParcelID;

SELECT a.ï»¿UniqueID,b.ï»¿UniqueID, a.ParcelID,  b.ParcelID,a.PropertyAddress, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress) FROM nashvillehousingdatafordatacleaningcsv a 
INNER JOIN nashvillehousingdatafordatacleaningcsv b 
ON a.ParcelID = b.ParcelID AND a.ï»¿UniqueID <> b.ï»¿UniqueID where a.PropertyAddress is null;


-- Updating the nashvillehousingdatafordatacleaning table so that there is no 2 addresses with the same ParcelID but one of them has no address
UPDATE nashvillehousingdatafordatacleaningcsv a
JOIN nashvillehousingdatafordatacleaningcsv b 
  ON a.ParcelID = b.ParcelID AND a.ï»¿UniqueID <> b.ï»¿UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;



-- 2
-- Updating the table so we separatee the Property address and the Property city columns
SELECT SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) as address,
SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1) as city 
FROM nashvillehousingdatafordatacleaningcsv;

ALTER TABLE nashvillehousingdatafordatacleaningcsv
ADD PropertySplitAddress varchar(255);

UPDATE nashvillehousingdatafordatacleaningcsv
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);

ALTER TABLE nashvillehousingdatafordatacleaningcsv
ADD PropertySplitCity varchar(255);
UPDATE nashvillehousingdatafordatacleaningcsv
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1);

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM nashvillehousingdatafordatacleaningcsv;


-- Updating the table so we separatee the Owner Address and city and state into multiple columns
SELECT SUBSTRING_INDEX(OwnerAddress, ',', 1), SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),SUBSTRING_INDEX(OwnerAddress, ',', -1)  
FROM nashvillehousingdatafordatacleaningcsv;

ALTER TABLE nashvillehousingdatafordatacleaningcsv ADD OwnerSplitState varchar(255);
ALTER TABLE nashvillehousingdatafordatacleaningcsv ADD OwnerSplitCity varchar(255);
ALTER TABLE nashvillehousingdatafordatacleaningcsv ADD OwnerSplitAddress varchar(255);

UPDATE nashvillehousingdatafordatacleaningcsv
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

UPDATE nashvillehousingdatafordatacleaningcsv
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

UPDATE nashvillehousingdatafordatacleaningcsv
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);



SELECT * FROM nashvillehousingdatafordatacleaningcsv;



-- 3 Fixing the SoldAsVacant column 
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousingdatafordatacleaningcsv
GROUP BY SoldAsVacant order by 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN 'No'
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
     ELSE SoldAsVacant
     END
FROM nashvillehousingdatafordatacleaningcsv;

UPDATE nashvillehousingdatafordatacleaningcsv
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
     ELSE SoldAsVacant
     END;


-- 4 Deleting duplicate data
-- we create a cte with a window function to number all the rows which have the same data
WITH RowNumberCTE AS (
  SELECT 
    ï»¿UniqueID,
    ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY ï»¿UniqueID) AS rownumber
  FROM nashvillehousingdatafordatacleaningcsv
)
-- Then we delete that data by deleting the 2nd rownumber by considering it as the duplicate
DELETE FROM nashvillehousingdatafordatacleaningcsv
WHERE ï»¿UniqueID IN (
  SELECT ï»¿UniqueID 
  FROM RowNumberCTE 
  WHERE rownumber > 1
);

-- 5 Deleting some no longer useful columns
ALTER TABLE nashvillehousingdatafordatacleaningcsv DROP COLUMN OwnerAddress;
ALTER TABLE nashvillehousingdatafordatacleaningcsv DROP COLUMN PropertyAddress;
SELECT * FROM nashvillehousingdatafordatacleaningcsv;