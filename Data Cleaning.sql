SELECT 
	* 
FROM 
	Nashville

-----------------------------------------------------

-- #1 Standrize Date Format 

SELECT 
	SaleDate, CONVERT(DATE, SaleDate) 
FROM 
	Nashville
ALTER TABLE 
	Nashville
ADD 
	SalesDateUpdated DATE; 
UPDATE 
	Nashville 
SET 
	SalesDateUpdated = CONVERT(DATE, SaleDate)
SELECT 
	SalesDateUpdated 
FROM 
	Nashville

-----------------------------------------------------

-- #2 Populate Property Address Data

SELECT 
	a.ParcelID, b.ParcelID, 
	a.PropertyAddress, b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress) PropertyAddressUpdated
FROM 
	Nashville a 
JOIN 
	Nashville b 
ON 
	a.ParcelID = b.ParcelID AND 
	a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress IS NULL

UPDATE a 
	SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	Nashville a 
JOIN 
	Nashville b 
ON 
	a.ParcelID = b.ParcelID AND 
	a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress IS NULL

----------------------------------------------------

-- #3 Breaking out Address into Individual Columns (Adress, City)

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) City
FROM 
	Nashville

ALTER TABLE 
	Nashville
ADD 
	SubAddress NVARCHAR(255),
	SubCity NVARCHAR(255)
UPDATE 
	Nashville
SET
	SubAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
UPDATE 
	Nashville
SET
	SubCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))

----------------------------------------------------

-- #4 Breaking out OwnerAddress into Individual Columns with PARSENAME

SELECT 
	OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) SubOwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) SubOwnerCity,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) SubOwnerState
FROM 
	Nashville

ALTER TABLE 
	Nashville

ADD 
	SubOwnerAddress NVARCHAR(255), 
	SubOwnerCity NVARCHAR(255), 
	SubOwnerState NVARCHAR(255)
UPDATE 
	Nashville
SET 
	SubOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
	SubOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	SubOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1

----------------------------------------------------

-- #5 Change Y and N to Yes and No in SoldAsVacant Column

SELECT 
	SoldAsVacant, 
CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END SoldAsVacantUpdated
FROM 
	Nashville

ALTER TABLE 
	Nashville
ADD 
	SoldAsVacantUpdated NVARCHAR(255)
UPDATE 
	Nashville
SET 
	SoldAsVacantUpdated = CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END
----------------------------------------------------

-- #6 Remove Duplicates 

with RowNumberCTE as(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 LegalReference
				 ORDER BY 
					UniqueID
					) RowNumber
FROM Nashville
--ORDER BY 
	--ParcelID
)
DELETE
FROM RowNumberCTE
WHERE RowNumber > 1

----------------------------------------------------

-- #7 Delete Unused Columns 

ALTER TABLE 
	Nashville
DROP COLUMN 
	PropertyAddress,
	SaleDate, 
	SoldAsVacant,
	OwnerAddress, 
	Address 

