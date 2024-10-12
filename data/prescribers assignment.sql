 --1 a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

 
 SELECT pb.npi, SUM(total_claim_count) as total_count
 FROM prescription AS pb
 GROUP BY pb.npi
 ORDER BY  total_count DESC
 LIMIT 1;

 
    --1 b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, 
 -- specialty_description, and the total number of claims.

 SELECT pp.nppes_provider_first_name, pp.nppes_provider_last_org_name, 
 pp.specialty_description, SUM(pb.total_claim_count) as total_count
 FROM prescription AS pb
 INNER JOIN prescriber AS pp
 ON pb.npi = pp.npi
 GROUP BY pp.nppes_provider_first_name, pp.nppes_provider_last_org_name, 
 pp.specialty_description
 ORDER BY  total_count DESC
 LIMIT 1;


 2. 
    -- a. Which specialty had the most total number of claims (totaled over all drugs)?
 SELECT npi, total_claim_count
 FROM prescription
 ORDER BY npi

 SELECT pb.specialty_description, SUM(pp.total_claim_count) AS total_claim
 FROM prescriber AS pb
 INNER JOIN prescription AS pp
 ON pb.npi = pp.npi
 GROUP BY pb.specialty_description
 ORDER BY total_claim desc
 LIMIT 1;



    -- b. Which specialty had the most total number of claims for opioids?

  SELECT pb.specialty_description, SUM(pp.total_claim_count) AS total_claim
  FROM prescriber AS pb
  INNER JOIN prescription AS pp
  ON pb.npi = pp.npi 
  INNER JOIN drug AS d
  ON pp.drug_name = d.drug_name
  WHERE d.opioid_drug_flag = 'Y'
  GROUP BY pb.specialty_description
  ORDER BY total_claim DESC
  LIMIT 1;

--2c.     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions 
-- in the prescription table?

  SELECT DISTINCT specialty_description
  FROM Prescriber AS pb
  LEFT JOIN prescription AS b 
  ON pb.npi= b.npi
  WHERE b.npi IS NULL

  -- SELECT * 
  -- FROM drug

  -- SELECT *
  -- FROM prescription

--3. 
    -- a. Which drug (generic_name) had the highest total drug cost?

	SELECT d.generic_name, SUM(pp.total_drug_cost) AS total_cost
	FROM drug AS d
	INNER JOIN prescription AS pp
	ON d.drug_name = pp.drug_name
	GROUP BY d.generic_name
	ORDER BY total_cost DESC
	LIMIT 10;


	-- SELECT d.generic_name, pp.total_drug_cost
	-- FROM drug AS d
	-- INNER JOIN prescription AS pp
	-- ON d.drug_name = pp.drug_name
	-- ORDER BY  d.generic_name DESC;
	


	
	 --ASK DIBRAN -- b. Which drug (generic_name) has the hightest total cost per day?

	SELECT 
	     d.generic_name, ROUND(SUM(total_drug_cost)/SUM (total_day_supply),2) AS total_cost_per_day 
	FROM drug AS d
	INNER JOIN prescription AS pp
	ON d.drug_name = pp.drug_name
	GROUP BY d.generic_name
    ORDER BY total_cost_per_day DESC
	LIMIT 1;



	--4. 
    -- a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for 
-- drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag =
 -- 'Y', and says 'neither' for all other drugs .

 
  SELECT DISTINCT drug_name,
  CASE
    WHEN opioid_drug_flag = 'Y' THEN 'opioid' 
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END AS drug_type
	FROM drug;

-- 4.
-- 	 b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics.
--  Hint: Format the total costs as MONEY for easier comparision.

   SELECT 
   CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid' 
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' END AS drug_type,
		 CAST(SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_drug_cost 
		 
   WHEN antibiotic_drug_flag = 'Y' THEN total_drug_cost END) as money) AS total_drug_cost
   FROM drug AS a 
   JOIN prescription AS b
   ON a.drug_name = b.drug_name
   WHERE CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid' 
   WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' END IS NOT NULL
   GROUP BY CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid' 
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' END
   ORDER BY total_drug_cost DESC;




-- 5a. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

   SELECT  
        COUNT(state) AS cbsa_tn
   FROM cbsa AS c
   INNER JOIN fips_county AS f
   ON c.fipscounty = f.fipscounty
   WHERE state = 'TN'
   ORDER BY cbsa_tn DESC;



-- 5b   b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

   SELECT  
         c.cbsaname,  SUM(population) as Total_Population
   FROM cbsa AS c
   INNER JOIN fips_county AS f
   ON c.fipscounty = f.fipscounty
   INNER JOIN population pop
   ON pop.fipscounty = f.fipscounty
   WHERE state = 'TN'
   GROUP BY c.cbsaname
   ORDER BY Total_Population DESC;


--5c c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

   SELECT   
         f.county, SUM(population) as Total_Population
   FROM cbsa AS c
   RIGHT JOIN fips_county AS f
   ON c.fipscounty = f.fipscounty
   RIGHT JOIN population pop
   ON pop.fipscounty = f.fipscounty
   WHERE state = 'TN' AND c.cbsaname IS NULL
   GROUP BY f.county
   ORDER BY Total_Population DESC
   LIMIT 1;

   
   -- SELECT * 
   -- FROM cbsa
   -- WHERE state;

--6a
--Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

   SELECT 
        drug_name, total_claim_count
   FROM prescription
   WHERE total_claim_count >= '3000';

--6b
--For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

  SELECT 
       a.drug_name, total_claim_count, 
  CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
  ELSE NULL END AS opioidFlag
  FROM prescription AS a 
  INNER JOIN drug AS b 
  ON a.drug_name = b.drug_name
  WHERE total_claim_count >= '3000';


--6c
--Add another column to you answer from the previous part which gives the prescriber first and last --name associated with each row.

 SELECT 
      a.drug_name, total_claim_count, 
 CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid' 
 ELSE NULL END AS opioidFlag, CONCAT (c.nppes_provider_first_name, ' ', c.nppes_provider_last_org_name) AS full_name
 FROM prescription AS a
 JOIN drug AS b
 ON a.drug_name = b.drug_name
 INNER JOIN prescriber AS c 
 ON c.npi = a.npi
 WHERE total_claim_count >= '3000';




--7a.
--First, create a list of all npi/drug_name combinations for pain management specialists
 --(specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 
 --'NASHVILLE'), 
--where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before 
--running it. 
--You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

  SELECT 
       c.npi, a.drug_name
  FROM drug AS a 
  JOIN prescription AS b 
  ON a.drug_name = b.drug_name
  INNER JOIN prescriber AS c 
  ON c.npi = b.npi
  WHERE c.specialty_description = 'Pain Management' AND c.nppes_provider_city = 'NASHVILLE'
	AND a.opioid_drug_flag = 'Y';


--7b
 --Next, report the number of claims per drug per prescriber. Be sure to include all combinations,
 --whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
 
  SELECT 
        c.npi, a.drug_name, specialty_description, nppes_provider_city, opioid_drug_flag
  FROM drug AS a 
 CROSS JOIN prescription AS b 
  WHERE c.specialty_description = 'Pain Management' AND c.nppes_provider_city = 'NASHVILLE'
  AND a.opioid_drug_flag = 'Y';

--7c
--Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

  SELECT 
        a.specialty_description ,a.nppes_provider_city 
  FROM prescriber AS a 
  LEFT JOIN prescription AS b 
  ON a.npi = b.npi
  WHERE a.specialty_description = 'Pain Management' AND a.nppes_provider_city like '%NASHVILLE%'

 -- select * 
 -- from 
 -- prescriber 
 -- where specialty_description = 'Pain Management' AND nppes_provider_city like '%NASHVILLE%'
 -- Select *
 -- From drug
 -- where opioid_drug_flag = 'Y'


 -- select *
 -- from ( select * 
 -- from 
 -- prescriber 
 -- where specialty_description = 'Pain Management' AND nppes_provider_city like '%NASHVILLE%')a
 -- left join prescription b on a.npi = b.npi
 -- left join (Select *
 -- From drug
 -- where opioid_drug_flag = 'Y')c on b.drug_name = c.drug_name



--  select  *from prescriber 
--  where specialty_description ilike '%management%' and nppes_provider_city ilike '%nashville%'
-- order by specialty_description
--  select  *from prescriber 
--  where nppes_provider_city ilike '%nashville%'
-- order by specialty_description