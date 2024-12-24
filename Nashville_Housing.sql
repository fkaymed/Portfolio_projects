select *
from portfolioproject.dbo.NashVille_Housing

--Standardize the Saledate format
Alter table portfolioproject.dbo.NashVille_Housing
Add New_SaleDate Date

update Portfolioproject.dbo.NashVille_Housing
set New_SaleDate = convert(Date, SaleDate)


--Populate PropertyAddress
select a.ParcelID, b.parcelid, a.propertyaddress, b.propertyaddress, ISNULL(b.propertyaddress,a.PropertyAddress)
from portfolioproject.dbo.NashVille_Housing a join portfolioproject.dbo.NashVille_Housing b 
on a.[UniqueID ] <> b.[UniqueID ] and a.ParcelID = b.ParcelID
where b.PropertyAddress is null

update b
set Propertyaddress =  ISNULL(b.propertyaddress,a.PropertyAddress)
from portfolioproject.dbo.NashVille_Housing a join portfolioproject.dbo.NashVille_Housing b 
on a.[UniqueID ] <> b.[UniqueID ] and a.ParcelID = b.ParcelID
where b.PropertyAddress is null


--Breaking out Address into individual columns
--+++++++
select SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1),
 SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, len(propertyaddress))
from portfolioproject.dbo.NashVille_Housing

Alter table portfolioproject.dbo.NashVille_Housing
Add Streetaddress nvarchar(255)

Alter table portfolioproject.dbo.NashVille_Housing
Add Townaddress nvarchar(255)

Update portfolioproject.dbo.NashVille_Housing
set Streetaddress =  SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

Update portfolioproject.dbo.NashVille_Housing
set Townaddress =  SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, len(propertyaddress))

--+++++++
select PARSENAME(replace(Owneraddress,',','.'),1)
from portfolioproject.dbo.NashVille_Housing
Alter table portfolioproject.dbo.NashVille_Housing
Add Country_address nvarchar (255)
Alter table portfolioproject.dbo.NashVille_Housing
Add City_address nvarchar (255)
Alter table portfolioproject.dbo.NashVille_Housing
Add Lane_address nvarchar (255)

Update portfolioproject.dbo.NashVille_Housing
set Country_address = PARSENAME(replace(Owneraddress,',','.'),1)
Update portfolioproject.dbo.NashVille_Housing
set City_address = PARSENAME(replace(Owneraddress,',','.'),2)
Update portfolioproject.dbo.NashVille_Housing
set Lane_address = PARSENAME(replace(Owneraddress,',','.'),3)


--Change Y and N to 'Yes' and 'No'
select distinct (soldasvacant), COUNT (soldasvacant)
from portfolioproject.dbo.NashVille_Housing
group by soldasvacant

select Soldasvacant, case when Soldasvacant ='Y' then 'Yes'
  when soldasvacant ='N' then 'No'
  else Soldasvacant
  end
  from portfolioproject.dbo.NashVille_Housing

update portfolioproject.dbo.NashVille_Housing
set SoldAsVacant = case when Soldasvacant ='Y' then 'Yes'
						  when soldasvacant ='N' then 'No'
						  else Soldasvacant
						  end


--Remove duplicates
with rownum as(
Select *,
ROw_number() over(partition by parcelid, propertyaddress, Saledate, Saleprice, legalreference
order by uniqueid)row_nums


from portfolioproject.dbo.NashVille_Housing
)
delete
from rownum
where row_nums > 1


--Delete unused columns
Alter table portfolioproject.dbo.NashVille_Housing
Drop Column SaleDate, OwnerAddress, Street_address,Town_address

