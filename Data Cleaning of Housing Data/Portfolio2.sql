--1 Standardize Data Format
Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate=CONVERT(Date,SaleDate)

ALter Table NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted=CONVERT(Date,SaleDate)

Select SaleDate, SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing

--2 Populate Property Address data
Select *
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
Order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null

--3 Breaking out Address into Individual Columns(Address, City,State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select 
Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
ADD PropertySplitAddress nvarchar(255);
Update NashvilleHousing
Set PropertySplitAddress=Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
ADD PropertySplitCity nvarchar(255);
Update NashvilleHousing
Set PropertySplitCity=Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
From  PortfolioProject.dbo.NashvilleHousing


Select *
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE (OwnerAddress,',','.'),3),
PARSENAME(REPLACE (OwnerAddress,',','.'),2),
PARSENAME(REPLACE (OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);
Update NashvilleHousing
Set OwnerSplitAddress=PARSENAME(REPLACE (OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
ADD OwnerSplitCity nvarchar(255);
Update NashvilleHousing
Set OwnerSplitCity=PARSENAME(REPLACE (OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
ADD OwnerSplitState nvarchar(255);
Update NashvilleHousing
Set OwnerSplitState=PARSENAME(REPLACE (OwnerAddress,',','.'),1)

--4 Change Y and N to Yes and No in 'Solid as Vacant' field
Select SoldAsVacant,Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant 
	 End
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant=
CASE when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant 
	 End

--5 Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing )
--order by ParcelID

Delete 
From RowNumCTE where row_num>1

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress
Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate
