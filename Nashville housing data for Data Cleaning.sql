/*
	CLEANING DATA IN SQL QUERIES

*/
	
Select *
from [Portfolio project]..NashvilleHousing

--Stanadarize  Date Format
Select SaleDateConverted, CONVERT(DATE,SaleDate)
from [Portfolio project]..NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(DATE,SaleDate)


--Populate Propertey Address Data

Select *
From [Portfolio project]..NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio project]..NashvilleHousing a
JOIN [Portfolio project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio project]..NashvilleHousing a
JOIN [Portfolio project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	where a.PropertyAddress is null



--Breaking Out address into Individual columns (Address, City, State)

Select PropertyAddress
From [Portfolio project]..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address

From [Portfolio project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


Select *
From [Portfolio project]..NashvilleHousing



Select OwnerAddress
from [Portfolio project]..Nashvillehousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From [Portfolio project]..NashvilleHousing



ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)




--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Portfolio project]..Nashvillehousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
from [Portfolio project]..Nashvillehousing

Update [Portfolio project]..Nashvillehousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END


--REMOVE DUPLICATES

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from [Portfolio project]..Nashvillehousing
)
DELETE
from RowNumCTE
Where row_num > 1


-- Delete Unused Columns

ALTER TABLE [Portfolio project]..Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate

Select *
From [Portfolio project]..Nashvillehousing
