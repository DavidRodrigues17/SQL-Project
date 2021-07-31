SELECT *
FROM Housing 

--- Date changing

SELECT SaleDate, CONVERT(DATE,SaleDate) as NewDate
FROM Housing 

ALTER TABLE Housing
ADD NewDate date

UPDATE Housing
SET NewDate = CONVERT(DATE,SaleDate) 

ALTER TABLE Housing
DROP COLUMN
SaleDate 

-- property address
SELECT PropertyAddress
FROm Housing
WHERE PropertyAddress is not null
order by 1


SELECT *
FROM Housing
WHERE PropertyAddress is null
oRDER BY 2

SELECT one.ParcelID,one.PropertyAddress, two.ParcelID, two.PropertyAddress, ISNULL(one.PropertyAddress, two.PropertyAddress)
FROM Housing one
JOIN Housing two
on one.ParcelID = two.ParcelID
AND one.[UniqueID ]<> two.[UniqueID ]
WHERE one.PropertyAddress is null

UPDATE one
SET PropertyAddress = ISNULL(one.PropertyAddress, two.PropertyAddress)
FROM Housing one
JOIN Housing two
on one.ParcelID = two.ParcelID
AND one.[UniqueID ]<> two.[UniqueID ]
WHERE one.PropertyAddress is null
 
 --- Seperating ADDRESS in individual columns
 
SELECT PropertyAddress
FROM Housing
WHERE PropertyAddress is null


SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) as Address
FROM Housing



ALTER TABLE Housing
ADD PropertySsplitAddress varchar(100)

UPDATE Housing
SET PropertySsplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


ALTER TABLE Housing
ADD PropertyCity varchar(100)


UPDATE Housing
SET PropertyCity =  SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))

ALTER TABLE Housing
DROP COLUMN
PropertyAddress

SELECT *
FROM Housing

SELECT OwnerAddress
FROM Housing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM Housing


ALTER TABLE Housing
Add OwnerSplitAddress Nvarchar(255);

UPDATE Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Housing
Add OwnerSplitCity Nvarchar(255);

UPDATE Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Housing
Add OwnerSplitState Nvarchar(255);

UPDATE Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

ALTER TABLE Housing
DROP COLUMN
OwnerAddress


SELECT OwnerSplitAddress, OwnerSplitCity,OwnerSplitState
FROM Housing
WHERE OwnerSplitState is not null
AND OwnerSplitAddress is not null
AND OwnerSplitCity is not null

--Change Y and N to Yes and No in "Sold as Vacant" Column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing
GROUP BY  SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Housing


Update Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

 -- Delete Unused Columns


SELECT *
FROM Housing

ALTER TABLE Housing
DROP COLUMN TaxDistrict

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 NewDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM Housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
