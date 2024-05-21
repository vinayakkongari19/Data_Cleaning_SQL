
 
--Cleaning Data in SQL Queries


select * from 
[Data_Cleaning].dbo.housing_data;


-- Standardize Date Format

alter table housing_data
add saledateconverted date
 
update Housing_data
 set SaleDate=convert (date,SaleDate)

 select saledateconverted = convert(date,saledate)
 from [Data_Cleaning].dbo.housing_data;

  update Housing_data
 set Saledateconverted  =convert (date,SaleDate)




 -- Populate Property Address data

 select *
 from Housing_data 
 where PropertyAddress is null

 select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL (a.propertyaddress,b.PropertyAddress)
 from Housing_data a
 join housing_data b 
     on a.ParcelID=b.ParcelID
	 and a.[uniqueid ] <> b.[uniqueid ]
where a.PropertyAddress is null

update a 
set propertyaddress= ISNULL (a.propertyaddress,b.PropertyAddress)
 from Housing_data a
 join housing_data b 
     on a.ParcelID=b.ParcelID 
	 and a.[uniqueid ] <> b.[uniqueid ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

 select PropertyAddress
 from Housing_data 

 select 
 SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)as address
 ,SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1, len(propertyaddress))as address
 from Housing_data

 alter table housing_data
add propertysplitaddress nvarchar(255)
 
 update Housing_data
 set propertysplitaddress =SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)

 alter table housing_data
add propertysplitcity nvarchar(255)

  update Housing_data
 set propertysplitcity =SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1, len(propertyaddress))

 select * 
 from [Data_Cleaning].dbo.housing_data;

 --owneraddress

 select OwnerAddress 
 from [Data_Cleaning].dbo.housing_data;

 select
 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Housing_data

ALTER TABLE housing_data
Add OwnerSplitAddress Nvarchar(255);

Update Housing_data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE housing_data
Add OwnerSplitCity Nvarchar(255);

Update Housing_data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE housing_data
Add OwnerSplitState Nvarchar(255);

Update Housing_data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


select* from Housing_data	


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct (SoldAsVacant),count(SoldAsVacant)
from Housing_data
group by SoldAsVacant
order by soldasvacant

select SoldAsVacant,
case when SoldAsVacant='Y'then 'YEs'
     when SoldAsVacant='N'then 'NO'
	 else SoldAsVacant
	 end
from Housing_data

update Housing_data
set SoldAsVacant=case when SoldAsVacant='Y'then 'YEs'
     when SoldAsVacant='N'then 'NO'
	 else SoldAsVacant
	 end

-- Remove Duplicates

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
from Housing_data)
select * from RowNumCTE
where row_num>1
order by PropertyAddress


-- Delete Unused Columns

select *
from Housing_data

alter table housing_data
drop column owneraddress,taxdistrict,propertyaddress


alter table housing_data
drop column saledate
