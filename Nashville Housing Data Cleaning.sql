SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Fill out Null rows in PropertyAddress based on ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

-- Breaking Down Address into (Street, City, State)

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertyStreet Nvarchar(255)

UPDATE NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertyCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerStreet NvarChar(255),
OwnerCity Nvarchar(255),
OwnerState NvarChar(255)

UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
OwnerCity =PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Change Y and N into Yes and No in "SoldAsVacant" Column


SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) AS Count
FROM NashvilleHousing
GROUP BY SoldAsVacant
Order by Count desc

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y'THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END

-- Removing Duplicates

WITH RowNumCTE AS (
SELECT *, Row_Number()OVER(partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) row_num
FROM NashvilleHousing
)

DELETE
FROM RowNumCTE 
WHERE row_num > 1

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

SELECT * 
FROM NashvilleHousing












