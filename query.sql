SET @DAT_PERIODO := (SELECT MAX(`periodo`) FROM `stg_aging_canal`);
DELETE FROM `stg_meta_faturamento` WHERE `periodo` = @DAT_PERIODO;
INSERT INTO `stg_meta_faturamento`(
SELECT 	`periodo`, 
	`escritorio_vendas`, 
	`equipe_vendas`, 
	`codigo_familia_produto`, 
	`familia_de_produto`, 
	`meta`, 
	`meta_volume`
	 
FROM 
	`stg_meta_faturamento` 
);


SET @DAT_PERIODO := (SELECT MAX(`periodo`) FROM `stg_meta_aging_canal_tri`);// falta arquivo
SET @DAT_PERIODO := (SELECT MAX(`periodo`) FROM `stg_politica_preco`);// falta arquivo
gera arquivos aging/ parou no aging_lp_canal_gerentes