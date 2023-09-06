-- In this project, we will be cleaning the data of a Nashville Housing Details data set.

-- getting all the data
select * 
from PortfolioProject..NashvilleHousing

-- standardizing the SaleDate field (removing time)

select SaleDate, CONVERT(Date, SaleDate)
from NashvilleHousing

-- updating the table using the converted date
update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)  -- OR

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- populating PropertyAddress
select PropertyAddress
from PortfolioProject..NashvilleHousing

-- checking if we have null values
select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

-- there are cases where, for the same ParcelID, sometimes the PropertyAddress is null, to keep it consistent

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] -- so its a different row
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] -- so its a different row
where a.PropertyAddress is null


-- Separating address into individual columns (Address, City, State)
select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

-- adding this into different columns
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select * 
from PortfolioProject..NashvilleHousing

-- separating OwnerAddress using parsename instead of substring

select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)-- since parsing uses periods, i am replacing periods with commas
from NashvilleHousing

-- adding into table
ALTER TABLE NashvilleHousing
ADD OwnersplitAddress nvarchar(255)

update NashvilleHousing
SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnersplitCity nvarchar(255)

update NashvilleHousing
SET OwnersplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnersplitState nvarchar(255)

update NashvilleHousing
SET OwnersplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-- changing Y and N to Yes and No in SoldAsVacant field
select distinct(soldasvacant), count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

-- using cases to change y to yes and n to no
select SoldAsVacant,
CASE	when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END
from NashvilleHousing

--updating table
Update NashvilleHousing
SET SoldAsVacant = CASE	when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						ELSE SoldAsVacant
						END
from NashvilleHousing

--select distinct(SoldAsVacant) 
--from PortfolioProject..NashvilleHousing


----- REMOVING DUPLICATES
--using CTE

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing
)
select * from RowNumCTE
where row_num > 1
order by PropertyAddress

-- to delete
WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing
)
DELETE from RowNumCTE
where row_num > 1


--DELETE UNUSED ITEMS
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

select *
from PortfolioProject..NashvilleHousing