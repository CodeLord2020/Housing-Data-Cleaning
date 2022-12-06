--Select top (100)
--[UniqueID],
--[ParcelID],
--[LandUse],
--[PropertyAddress],
--[SaleDate],
--[SalePrice],
--[LegalReference],
--[SoldAsVacant],
--[OwnerName],
--[OwnerAddress],
--[Acreage],
--[TaxDistrict],	
--[LandValue],
--[BuildingValue],
--[TotalValue],
--[YearBuilt],
--[Bedrooms],
--[FullBath],
--[HalfBath]

--from PortfolioProject..[Nashville Housing]

--Resolving SaleDate format

Select FormattedSaleDate
from PortfolioProject..[Nashville Housing]

Alter table [Nashville Housing]
add FormattedSaleDate date

update [Nashville Housing]
set FormattedSaleDate = convert(date, SaleDate)




--Populate 'NULL' Propery Address in data

--Select PropertyAddress
--from PortfolioProject..[Nashville Housing]
--where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject..[Nashville Housing] a
join PortfolioProject..[Nashville Housing] b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID] <> b.[UniqueID ]
 where a.PropertyAddress is null
 
 --Updating
 Update a
Set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject..[Nashville Housing] a
join PortfolioProject..[Nashville Housing] b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID] <> b.[UniqueID ]
where a.PropertyAddress is null



---- Breaking down Address into (address,city, state)

---PropertyAddress

Select 
Parsename(replace(PropertyAddress, ',' ,'.'),2)as PropertySplitAddress,
Parsename(replace(PropertyAddress, ',' ,'.'),1) as PropertySplitCity
from PortfolioProject..[Nashville Housing]

Alter table  [Nashville Housing]
add  PropertySplitAddress nvarchar(255);
Alter table  [Nashville Housing]
add  PropertySplitCity nvarchar(255);

Update [Nashville Housing]
Set PropertySplitAddress = Parsename(replace(PropertyAddress, ',' ,'.'),2)
Update [Nashville Housing]
Set PropertySplitCity = Parsename(replace(PropertyAddress, ',' ,'.'),1)

---OwnerAddress

Select
Parsename(replace(OwnerAddress, ',' ,'.'),3),
Parsename(replace(OwnerAddress, ',' ,'.'),2),
Parsename(replace(OwnerAddress, ',' ,'.'),1)
from PortfolioProject..[Nashville Housing]

Alter table  [Nashville Housing]
add  OwnerSplitAddress nvarchar(255);
Alter table  [Nashville Housing]
add  OwnerSplitCity nvarchar(255);
Alter table  [Nashville Housing]
add  OwnerSplitState nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitAddress = Parsename(replace(OwnerAddress, ',' ,'.'),3)
Update [Nashville Housing]
Set OwnerSplitCity = Parsename(replace(OwnerAddress, ',' ,'.'),2)
Update [Nashville Housing]
Set OwnerSplitState = Parsename(replace(OwnerAddress, ',' ,'.'),1)

Select *
from PortfolioProject..[Nashville Housing]



--Resolving (YES, NO, Y, N) in SoldAsVacant
select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..[Nashville Housing]
Group by SoldAsVacant
order by count(SoldAsVacant)

Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant --leave as it is
	 END
from PortfolioProject..[Nashville Housing]

Update [Nashville Housing]
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant --leave as it is
	 END


	 ----Remove Duplicates

With RowNumCTE as (
Select *,
ROW_NUMBER() OVER( 
         Partition by ParcelID,
		              PropertyAddress,
					  SalePrice,
					  SaleDate,
					  LegalReference
					 ORDER by 
					    UniqueID
					  )row_num
from PortfolioProject..[Nashville Housing]
--Order by ParcelID
)
Delete
from RowNumCTE
where row_num > 1

With RowNumCTE as (
Select *,
ROW_NUMBER() OVER( 
         Partition by ParcelID,
		              PropertyAddress,
					  SalePrice,
					  SaleDate,
					  LegalReference
					 ORDER by 
					    UniqueID
					  )row_num
from PortfolioProject..[Nashville Housing]
--Order by ParcelID
)
Select*
from RowNumCTE
where row_num > 1
order by PropertyAddress



Alter Table PortfolioProject..[Nashville Housing]
Drop Column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

Select *
from PortfolioProject..[Nashville Housing]