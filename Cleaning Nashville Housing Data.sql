/* Cleaning Data in SQL Queries */

select * from PortfolioProject..NashvilleHousing

/* Standardise / Change Sale Date */

select SaleDateConverted, Convert(Date, SaleDate)
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
SET SaleDate = Convert(Date, SaleDate)

ALTER TABLE portfolioproject..nashvillehousing
Add SaleDateConverted Date;

update PortfolioProject..NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)

-- Populate Property Address data


select * from PortfolioProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress= ISNULL(a.propertyaddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress from PortfolioProject..NashvilleHousing

Select
Substring(propertyaddress, 1, CHARINDEX(',',PropertyAddress)-1 ) as Address
, Substring(propertyaddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

ALTER TABLE portfolioproject..nashvillehousing
Add PropertySplitAddress Nvarchar(255);

update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = Substring(propertyaddress, 1, CHARINDEX(',',PropertyAddress)-1 )

ALTER TABLE portfolioproject..nashvillehousing
Add PropertySplitCity Nvarchar(255);

update PortfolioProject..NashvilleHousing
SET PropertySplitCity = Substring(propertyaddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) 

select * from PortfolioProject..NashvilleHousing



select * from PortfolioProject..NashvilleHousing

Select
PARSENAME( REPLACE(OwnerAddress,',','.') , 3 )
,PARSENAME( REPLACE(OwnerAddress,',','.') , 2 )
,PARSENAME( REPLACE(OwnerAddress,',','.') , 1 )
from PortfolioProject..NashvilleHousing

ALTER TABLE portfolioproject..nashvillehousing
Add OwnerSplitAddress Nvarchar(255);

update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME( REPLACE(OwnerAddress,',','.') , 3 )



ALTER TABLE portfolioproject..nashvillehousing
Add OwnerSplitCity Nvarchar(255);

update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME( REPLACE(OwnerAddress,',','.') , 2 )



ALTER TABLE portfolioproject..nashvillehousing
Add OwnerSplitState Nvarchar(255);

update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME( REPLACE(OwnerAddress,',','.') , 1 )


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(soldasvacant), count(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2 desc

select SoldAsVacant
, CASE when soldasvacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
END
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
END


-- Remove Duplicates

WITH RowNumCTE AS (
select * 
,	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
		UniqueID
		) row_num
from PortfolioProject..NashvilleHousing
--order by parcelID
)
Select * -- DELETE 
From RowNumCTE
where row_num >1
order by PropertyAddress