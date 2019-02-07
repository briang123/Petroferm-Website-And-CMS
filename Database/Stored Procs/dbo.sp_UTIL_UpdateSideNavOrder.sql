




--sp_UTIL_UpdateSideNavOrder 4, 8, 0, 3, 38, 2

CREATE      PROC sp_UTIL_UpdateSideNavOrder(
	@BusId int = 0,
	@MktId int = 0,
	@ProdCatId int = 0,
	@SectionId int = 0,
	@ID int = 0,
	@ItemOrder int = 0
)
AS
BEGIN

/*
created by: Brian Gaines
created on: 11/25/2006

purpose: This script reorders the side navigation elements within a particular section by filtering on the following 
	parameters passed into this stored procedure. When a navigational element is being reordered, this script will 
	actually update the current element with the new ItemOrder and adjust all the other navigation elements so 
	that there is not a duplicate ItemOrder number within that section.

	Notes about usage:
	After testing this more thoroughly, I realized that it's imperitive to get the IDs correct that are being 
	passed into this procecure. If not, then the incorrect navigational elements will be reordered rendering
	some headache in the meantime. In order to fix this issue, I added a validation routine at the beginning 
	of the stored procedure to check if the record exists before continuing.

parameters:
	@BusId - The business unit id 
	@MktId - The market id (if at a business unit level, then pass in 0)
	@ProdCatId - The product category id (in case for product pages -- if we're not dealing with a product, then pass in 0)
	@SectionId - The section which we'd like to reorder our navigation elements
	@ID - The primary key of the tblSideNav table which is the *actual* navigation element we're reordering
	@ItemOrder - The target reorder number (if we're changing the current item from 5 to 3, then pass 3)

script usage syntax:
	exec sp_NLT_UpdateSideNavOrder 
		@BusId = 2, 
		@MktId = 1, 
		@ProdCatId = 1, 
		@SectionId = 1, 
		@ID = 16, 
		@ItemOrder = 2

history:
	Brian Gaines (11/25/2006) - Created initial stored procedure (and added the *if exists* validation routine)
	Kelly Roe    (03/18/2007) - Removed market id from where clauses -- don't need it
*/

if exists (select 1 from tblSideNav 
		where BusinessUnitID = @BusId
		--and MarketId in (@MktId, 0) -- don't need market id criterion - 3/18/07 - kr
		and ProdCatId = @ProdCatId
		and SectionID = @SectionId
		and ID = @ID)

BEGIN

	BEGIN TRAN
	
		DECLARE @maxOrder int
		SELECT 	@maxOrder = MAX(ItemOrder)
		FROM	tblSideNav
		where 	BusinessUnitId = @BusId
		--and	MarketId in (@MktId, 0) -- don't need market id criterion - 3/18/07 - kr
		and	SectionId = @SectionId
		and 	ProdCatId = @ProdCatId


		DECLARE @currentOrder int
		SELECT 	@currentOrder = ItemOrder
		FROM 	tblSideNav
		WHERE 	ID = @ID

		DECLARE @nextId int
		SELECT 	@nextId = ID
		FROM 	tblSideNav
		WHERE 	ItemOrder = @ItemOrder
		and	BusinessUnitId = @BusId
		--and	MarketId in (@MktId, 0) -- don't need market id criterion - 3/18/07 - kr
		and	SectionId = @SectionId
		and 	ProdCatId = @ProdCatId	


	
		IF ( @currentOrder <> @ItemOrder )
		BEGIN
			IF ( @ItemOrder = 1 )
			BEGIN
				UPDATE 	tblSideNav
				SET	ItemOrder = ItemOrder + 1
				WHERE	ItemOrder = @ItemOrder			
				and 	BusinessUnitId = @BusId
				--and	MarketId = @MktId -- don't need market id criterion - 3/18/07 - kr
				and	SectionId = @SectionId
				and 	ProdCatId = @ProdCatId
			END
			ELSE
			BEGIN
				IF ( @ItemOrder = @maxOrder ) 
				BEGIN						
					UPDATE 	tblSideNav
					SET	ItemOrder = @ItemOrder - 1
					WHERE	ID = @nextId
				END
				ELSE
				BEGIN
					UPDATE 	tblSideNav
					SET	ItemOrder = ItemOrder + 1
					WHERE	ItemOrder = @ItemOrder
					and	BusinessUnitId = @BusId
					--and	MarketId = @MktId -- don't need market id criterion - 3/18/07 - kr
					and	SectionId = @SectionId
					and 	ProdCatId = @ProdCatId
	
					UPDATE 	tblSideNav
					SET	ItemOrder = @ItemOrder - 1
					WHERE	ID = @nextId	
				END
			END			
		END
	
		UPDATE 	tblSideNav
		SET 	ItemOrder = @ItemOrder
		WHERE	ID = @ID
	
		SELECT 	ID, ItemOrder, BusinessUnitID, MarketID, SectionID, ProdCatID 
		INTO 	#tempSideNav 
		FROM 	tblSideNav
		where	BusinessUnitId = @BusId
		--and	MarketId in (@MktId, 0) -- don't need market id criterion - 3/18/07 - kr
		and	SectionId = @SectionId
		and 	ProdCatId = @ProdCatId
		ORDER BY ItemOrder
	
		DECLARE @counter int
		SELECT 	@counter = 0
		UPDATE 	#tempSideNav 
		SET 	@counter = ItemOrder = @counter + 1
		where	BusinessUnitId = @BusId
		--and	MarketId = @MktId -- don't need market id criterion - 3/18/07 - kr
		and	SectionId = @SectionId
		and 	ProdCatId = @ProdCatId
	
		UPDATE 	tblSideNav
		SET 	ItemOrder = 
			( 	SELECT 	ItemOrder 
				FROM 	#tempSideNav 
				WHERE 	ID = tblSideNav.ID)
		where	BusinessUnitId = @BusId
		--and	MarketId = @MktId -- don't need market id criterion - 3/18/07 - kr
		and	SectionId = @SectionId
		and 	ProdCatId = @ProdCatId	
	
		DROP TABLE #tempSideNav
	
	
		IF ( @@ERROR = 0 )
		BEGIN
			COMMIT TRAN
			RETURN 1
		END
		ELSE
		BEGIN
			ROLLBACK TRAN
			RETURN 0
		END
END
ELSE
BEGIN
	print 'A record does not exist based on the parameters you defined.'
	return 0
END

END