CREATE PROCEDURE proc_AssetCharge
AS
DECLARE @tb AS TABLE (Id INT, Balance INT, IsSet BIT);

	INSERT INTO @tb (Id, Balance, IsSet)
	VALUES (1,0,0),(2,10,1),(3,0,0),(4,0,0),(5,8,1),(6,7,1),(7,0,0)
		,(8,0,0),(9,-5,1),(10,0,0),(11, 0, 1),(12, 0, 0);

	WITH d1 AS
	(
		SELECT Id, Balance, IsSet, 
			RANK() OVER (PARTITION BY IsSet ORDER BY Id) RNK
		FROM @tb
	), d2 AS
	(
		SELECT Id, Balance, IsSet,
			MAX(CASE IsSet WHEN 0 THEN 0 ELSE RNK END) OVER (ORDER BY Id) RNK
		FROM d1
	), d3 AS
	(
		SELECT Id, Balance TransBalance,
			CASE IsSet WHEN 0 THEN
				MAX(Balance) OVER (PARTITION BY RNK ORDER BY Id) +
				MIN(Balance) OVER (PARTITION BY RNK ORDER BY Id) 
			ELSE
				Balance
			END AssetValue
		FROM d2
	)
	SELECT Id,
		CASE TransBalance 
			WHEN 0 THEN COALESCE(AssetValue - LAG(AssetValue) OVER (ORDER BY Id), 0)
			ELSE COALESCE(TransBalance - LAG(AssetValue) OVER (ORDER BY Id), 0)
			END Tx,
		AssetValue
	FROM d3;

