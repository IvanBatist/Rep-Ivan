SELECT * f_rom cli_leg_gross_sales_total WHERE nom_pessoa  IS NOT NULL AND nom_centro_custo = 'penha OT' AND dsc_familia = 'lays';
SELECT DISTINCT * FROM cli_leg_gross_sales_total 
WHERE vlr_alvo > vlr_realizado
AND nom_centro_custo = 'penha OT';
