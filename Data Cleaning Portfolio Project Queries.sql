/*

Cleaning Data in SQL Queries

*/

select *
From PortofolioProject.dbo.NashvileHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDateConverted, CONVERT(Date,SaleDate)
From PortofolioProject.dbo.NashvileHousing


Update NashvileHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvileHousing
Add SaleDateConverted Date;

Update NashvileHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortofolioProject.dbo.NashvileHousing
--Where PropertyAddress is null
Order by ParcelID	


Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortofolioProject.dbo.NashvileHousing a
JOIN PortofolioProject.dbo.NashvileHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortofolioProject.dbo.NashvileHousing a
JOIN PortofolioProject.dbo.NashvileHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortofolioProject.dbo.NashvileHousing
--Where PropertyAddress is null
--Order by ParcelID	

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress )) as City

From PortofolioProject.dbo.NashvileHousing

ALTER TABLE NashvileHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvileHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvileHousing
Add PropertySplitCity Nvarchar(255);

Update NashvileHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress ))


select *
From PortofolioProject.dbo.NashvileHousing


select OwnerAddress
From PortofolioProject.dbo.NashvileHousing

select
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From PortofolioProject.dbo.NashvileHousing

ALTER TABLE NashvileHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvileHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvileHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvileHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvileHousing
Add OwnerSplitState Nvarchar(255);

Update NashvileHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


select *
From PortofolioProject.dbo.NashvileHousing






--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortofolioProject.dbo.NashvileHousing
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant,
    CASE WHEN [SoldAsVacant] = 'Y' THEN 'Yes'
         WHEN [SoldAsVacant] = 'N' THEN 'No'
         ELSE [SoldAsVacant]
    END AS [Sold as Vacant]
FROM
    PortofolioProject.dbo.NashvileHousing 

UPDATE NashvileHousing
SET SoldAsVacant = 
	CASE WHEN [SoldAsVacant] = 'Y' THEN 'Yes'
         WHEN [SoldAsVacant] = 'N' THEN 'No'
         ELSE [SoldAsVacant]
    END

select *
From PortofolioProject.dbo.NashvileHousing



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE as(
Select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

From PortofolioProject.dbo.NashvileHousing
)
Select *
From RowNumCTE
Where row_num>1
Order by PropertyAddress


SELECT ParcelID, PropertyAddress, SalePrice,SaleDate,LegalReference, COUNT(*) as DuplicateCount
FROM PortofolioProject.dbo.NashvileHousing
GROUP BY ParcelID, PropertyAddress, SalePrice,SaleDate,LegalReference
HAVING COUNT(*) > 1

select *
From PortofolioProject.dbo.NashvileHousing





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
From PortofolioProject.dbo.NashvileHousing

alter table PortofolioProject.dbo.NashvileHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortofolioProject.dbo.NashvileHousing
drop column SaleDate










-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


















