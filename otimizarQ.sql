EXPLAIN SELECT
	DATE_FORMAT(result.periodo, '%d/%m/%Y') AS periodo,
	result.matricula,
	REPLACE(result.aging_meta, ".",",")AS aging_meta,
	REPLACE((
		IFNULL(CONVERT(
			(
				SUM(result.montante_usp_t1ha) - (IFNULL(SUM(result.montante_usp_t2ha), 0) + IFNULL(SUM(result.montante_usp_t3ha), 0))
			)
			/
			(SUM(result.montante_usp_t1ha) - IFNULL(SUM(result.montante_usp_t3ha), 0)) -- alterado dia 13/04/2015
			, DECIMAL(13, 6)
		), 0) -- aging_real_ha
		*
		IF(peso_ha.valor_peso IS NULL, (IFNULL(SUM(result.meta_ha), 0)), 
			IF(
				(IFNULL(SUM(result.meta_ha), 0)) = 1, 1,
				IF((IFNULL(SUM(result.meta_ha), 0)) = 0, 0,
				peso_ha.valor_peso)
			)
		) -- meta_ha
	)
	+
	(
		IFNULL(CONVERT(
			(
				SUM(result.montante_usp_t1ac) - (IFNULL(SUM(result.montante_usp_t2ac), 0) + IFNULL(SUM(result.montante_usp_t3ac), 0))
			)
			/
			(SUM(result.montante_usp_t1ac) - IFNULL(SUM(result.montante_usp_t3ac), 0)) -- alterado dia 13/04/2015
			, DECIMAL(13, 6)
		), 0) -- aging_real_ac
		*
		IF(peso_ac.valor_peso IS NULL, (IFNULL(SUM(result.meta_ac), 0)), 
			IF(
				(IFNULL(SUM(result.meta_ac), 0)) = 1, 1,
				IF((IFNULL(SUM(result.meta_ac), 0)) = 0, 0,
				peso_ac.valor_peso)
			)
		) -- meta_ac
	),".",",") AS aging_real
FROM
(
	SELECT
		cli_elegiveis.periodo,
		tg.matricula,
		CONVERT(cli_meta_aging_mes.meta, DECIMAL(13, 6)) AS aging_meta,
		tg.escritorio_vendas,

		SUM(t1ac.montante_usp) AS montante_usp_t1ac,
		SUM(t2ac.montante_usp) AS montante_usp_t2ac,
		SUM(t3ac.montante_usp) AS montante_usp_t3ac,

		SUM(t1ha.montante_usp) AS montante_usp_t1ha,
		SUM(t2ha.montante_usp) AS montante_usp_t2ha,
		SUM(t3ha.montante_usp) AS montante_usp_t3ha,

		(meta_faturamento_ac.meta / meta_faturamento_total.meta_total) AS meta_ac,
		(meta_faturamento_ha.meta / meta_faturamento_total.meta_total) AS meta_ha
	FROM
		(
			SELECT
				periodo,
				matricula,
				nome,
				escr_vendas AS escritorio_vendas
			FROM
				cli_territorio_vendedor
			WHERE
				periodo = '2015-05-01'
			GROUP BY
				periodo, matricula, escr_vendas
		) AS tg
	INNER JOIN
		cli_elegiveis
		ON
			cli_elegiveis.periodo = tg.periodo
		AND
			cli_elegiveis.matricula = tg.matricula
		LEFT JOIN
		(
			SELECT
				tmp_aging.periodo,
				tmp_aging.escritorio_vendas,
				SUM(tmp_aging.montante_usp) AS montante_usp
			FROM
				tmp_aging
			INNER JOIN
				tmp_de_para_ha_ac
				ON
					tmp_de_para_ha_ac.periodo = tmp_aging.periodo
				AND
					tmp_de_para_ha_ac.esc_vendas = tmp_aging.escritorio_vendas
			WHERE
				tmp_aging.periodo = '2015-05-01'
			AND
				tmp_de_para_ha_ac.linha_produto = "Ar Condicionado Residencial"
			GROUP BY
				1, 2
		) AS t1ac
			ON
				t1ac.periodo = tg.periodo
			AND
				t1ac.escritorio_vendas = tg.escritorio_vendas
		LEFT JOIN
		(
			SELECT
				tmp_aging.periodo,
				tmp_aging.escritorio_vendas,
				SUM(tmp_aging.montante_usp) AS montante_usp
			FROM
				tmp_aging
			INNER JOIN
				tmp_de_para_ha_ac
				ON
					tmp_de_para_ha_ac.periodo = tmp_aging.periodo
				AND
					tmp_de_para_ha_ac.esc_vendas = tmp_aging.escritorio_vendas
			WHERE
				tmp_aging.periodo = '2015-05-01'
			AND
				tmp_de_para_ha_ac.linha_produto = "Ar Condicionado Residencial"
			AND
				tmp_aging.cod_situacao = '1'
			GROUP BY
				1, 2
		) AS t2ac
			ON
				t2ac.periodo = tg.periodo
			AND
				t2ac.escritorio_vendas = tg.escritorio_vendas
		LEFT JOIN
		(
			SELECT
				tmp_aging.periodo,
				tmp_aging.escritorio_vendas,
				SUM(tmp_aging.montante_usp) AS montante_usp
			FROM
				tmp_aging
			INNER JOIN
				tmp_de_para_ha_ac
				ON
					tmp_de_para_ha_ac.periodo = tmp_aging.periodo
				AND
					tmp_de_para_ha_ac.esc_vendas = tmp_aging.escritorio_vendas
			WHERE
				tmp_aging.periodo = '2015-05-01'
			AND
				tmp_de_para_ha_ac.linha_produto = "Ar Condicionado Residencial"
			AND
				tmp_aging.cod_situacao = '7'
			GROUP BY
				1, 2
		) AS t3ac
			ON
				t3ac.periodo = tg.periodo
			AND
				t3ac.escritorio_vendas = tg.escritorio_vendas
		LEFT JOIN
		(
			SELECT
				tmp_aging.periodo,
				tmp_aging.escritorio_vendas,
				SUM(tmp_aging.montante_usp) AS montante_usp
			FROM
				tmp_aging
			INNER JOIN
				tmp_de_para_ha_ac
				ON
					tmp_de_para_ha_ac.periodo = tmp_aging.periodo
				AND
					tmp_de_para_ha_ac.esc_vendas = tmp_aging.escritorio_vendas
			WHERE
				tmp_aging.periodo = '2015-05-01'
			AND
				tmp_de_para_ha_ac.linha_produto = "Home Appliance"
			GROUP BY
				1, 2
		) AS t1ha
			ON
				t1ha.periodo = tg.periodo
			AND
				t1ha.escritorio_vendas = tg.escritorio_vendas
		LEFT JOIN
		(
			SELECT
				tmp_aging.periodo,
				tmp_aging.escritorio_vendas,
				SUM(tmp_aging.montante_usp) AS montante_usp
			FROM
				tmp_aging
			INNER JOIN
				tmp_de_para_ha_ac
				ON
					tmp_de_para_ha_ac.periodo = tmp_aging.periodo
				AND
					tmp_de_para_ha_ac.esc_vendas = tmp_aging.escritorio_vendas
			WHERE
				tmp_aging.periodo = '2015-05-01'
			AND
				tmp_de_para_ha_ac.linha_produto = "Home Appliance"
			AND
				tmp_aging.cod_situacao = '1'
			GROUP BY
				1, 2
		) AS t2ha
			ON
				t2ha.periodo = tg.periodo
			AND
				t2ha.escritorio_vendas = tg.escritorio_vendas
		LEFT JOIN
		(
			SELECT
				tmp_aging.periodo,
				tmp_aging.escritorio_vendas,
				SUM(tmp_aging.montante_usp) AS montante_usp
			FROM
				tmp_aging
			INNER JOIN
				tmp_de_para_ha_ac
				ON
					tmp_de_para_ha_ac.periodo = tmp_aging.periodo
				AND
					tmp_de_para_ha_ac.esc_vendas = tmp_aging.escritorio_vendas
			WHERE
				tmp_aging.periodo = '2015-05-01'
			AND
				tmp_de_para_ha_ac.linha_produto = "Home Appliance"
			AND
				tmp_aging.cod_situacao = '7'
			GROUP BY
				1, 2
		) AS t3ha
			ON
				t3ha.periodo = tg.periodo
			AND
				t3ha.escritorio_vendas = tg.escritorio_vendas
		LEFT JOIN
		(
			SELECT
				periodo,
				escritorio_vendas,
				SUM(meta) AS meta
			FROM
				cli_meta_faturamento_mes
			WHERE
				periodo = '2015-05-01'
			GROUP BY
				1, 2
		) AS cli_meta_faturamento_mes
			ON
				cli_meta_faturamento_mes.periodo = tg.periodo
			AND
				cli_meta_faturamento_mes.escritorio_vendas = tg.escritorio_vendas
		LEFT JOIN
		(
			SELECT
				cli_meta_faturamento_mes.periodo,
				cli_meta_faturamento_mes.escritorio_vendas,
				SUM(cli_meta_faturamento_mes.meta) AS meta
			FROM
				cli_meta_faturamento_mes
			INNER JOIN
				tmp_de_para_ha_ac
				ON
					tmp_de_para_ha_ac.periodo = cli_meta_faturamento_mes.periodo
				AND
					tmp_de_para_ha_ac.esc_vendas = cli_meta_faturamento_mes.escritorio_vendas
			WHERE
				cli_meta_faturamento_mes.periodo = '2015-05-01'
			AND
				tmp_de_para_ha_ac.linha_produto = "Ar Condicionado Residencial"
			GROUP BY
				1, 2
		) AS meta_faturamento_ac
			ON
				meta_faturamento_ac.periodo = tg.periodo
			AND
				meta_faturamento_ac.escritorio_vendas = tg.escritorio_vendas
		LEFT JOIN
		(
			SELECT
				cli_meta_faturamento_mes.periodo,
				cli_meta_faturamento_mes.escritorio_vendas,
				SUM(cli_meta_faturamento_mes.meta) AS meta
			FROM
				cli_meta_faturamento_mes
			INNER JOIN
				tmp_de_para_ha_ac
				ON
					tmp_de_para_ha_ac.periodo = cli_meta_faturamento_mes.periodo
				AND
					tmp_de_para_ha_ac.esc_vendas = cli_meta_faturamento_mes.escritorio_vendas
			WHERE
				cli_meta_faturamento_mes.periodo = '2015-05-01'
			AND
				tmp_de_para_ha_ac.linha_produto = "Home Appliance"
			GROUP BY
				1, 2
		) AS meta_faturamento_ha
			ON
				meta_faturamento_ha.periodo = tg.periodo
			AND
				meta_faturamento_ha.escritorio_vendas = tg.escritorio_vendas
		LEFT JOIN
		(
			SELECT
				cli_elegiveis.periodo AS periodo,
				tg.matricula,
				SUM(cli_meta_faturamento_mes.meta) AS meta_total
			FROM
				(
					SELECT
						periodo,
						matricula,
						nome,
						escr_vendas AS escritorio_vendas
					FROM
						cli_territorio_vendedor
					WHERE
						periodo = '2015-05-01'
					GROUP BY
						periodo, matricula, escr_vendas
				) AS tg
			INNER JOIN
				cli_elegiveis
				ON
					cli_elegiveis.periodo = tg.periodo
				AND
					cli_elegiveis.matricula = tg.matricula
				LEFT JOIN
				(
					SELECT
						periodo,
						escritorio_vendas,
						SUM(meta) AS meta
					FROM
						cli_meta_faturamento_mes
					WHERE
						periodo = '2015-05-01'
					GROUP BY
						1, 2
				) AS cli_meta_faturamento_mes
					ON
						cli_meta_faturamento_mes.periodo = tg.periodo
					AND
						cli_meta_faturamento_mes.escritorio_vendas = tg.escritorio_vendas
			WHERE
				cli_elegiveis.periodo = '2015-05-01'
			GROUP BY
				tg.matricula
		) AS meta_faturamento_total
			ON
				meta_faturamento_total.periodo = tg.periodo
			AND
				meta_faturamento_total.matricula = tg.matricula
	LEFT JOIN
		cli_meta_aging_mes
		ON
			cli_meta_aging_mes.periodo = cli_elegiveis.periodo
		AND
			cli_meta_aging_mes.canal = cli_elegiveis.canal
	WHERE
		cli_elegiveis.periodo = '2015-05-01'
	GROUP BY
		tg.matricula, tg.escritorio_vendas
) AS result
LEFT JOIN
	peso_linha_produto AS peso_ha
	ON
		peso_ha.periodo = result.periodo
	AND
		peso_ha.linha_produto = "Home Appliance"
LEFT JOIN
	peso_linha_produto AS peso_ac
	ON
		peso_ac.periodo = result.periodo
	AND
		peso_ac.linha_produto = "Ar Condicionado Residencial"
GROUP BY
	1, 2;