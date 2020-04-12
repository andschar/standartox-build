-- scripts to aggregate organism habitat and occurrence information

-- id table --------------------------------------------------------------------
DROP TABLE IF EXISTS taxa.taxa_id2;
CREATE TABLE taxa.taxa_id2 AS (
	SELECT
		ep.*
	FROM taxa.taxa_id id
	LEFT JOIN epa.epa_taxa ep USING (species_number)
);
ALTER TABLE taxa.taxa_id2 ADD PRIMARY KEY (species_number);

-- habitat --------------------------------------------------------------------
DROP TABLE IF EXISTS taxa.taxa_habitat;
CREATE TABLE taxa.taxa_habitat AS (
	SELECT
		id.species_number,
		id.taxon,
		-- NOTE GBIF is not included as many classificaitons seem wrong
		GREATEST(wo.brack, epa_habi.brackish)::boolean AS brack,
		GREATEST(fw.freshwater, wo.fresh, epa_habi.freshwater, epa_taxa.freshwater)::boolean AS fresh,
		GREATEST(wo.marin, epa_habi.marine, epa_taxa.marine)::boolean AS marin,
		GREATEST(wo.terre, epa_habi.terrestrial, epa_taxa.terrestrial)::boolean AS terre
	FROM taxa.taxa_id id
	LEFT JOIN worms.worms_data wo USING (taxon)
	LEFT JOIN fwecology.fwecology_data fw USING (taxon)
	LEFT JOIN epa.epa_habi epa_habi USING (species_number)
	LEFT JOIN epa.epa_taxa epa_taxa USING (species_number)
);
ALTER TABLE taxa.taxa_habitat ADD PRIMARY KEY (species_number);

-- trophic level --------------------------------------------------------------
DROP TABLE IF EXISTS taxa.taxa_trophic_lvl;
CREATE TABLE taxa.taxa_trophic_lvl AS (
	SELECT
		id.species_number,
		id.taxon,
		GREATEST(ep.autotroph, fw.diatom, fw.macrophyte, fw.phytoplankton)::boolean AS autotroph,
		GREATEST(ep.heterotroph, fw.fish, fw.invertebrate_macro)::boolean AS heterotroph,
		GREATEST(ep.mixotroph)::boolean AS mixotroph
	FROM taxa.taxa_id id
	LEFT JOIN epa.epa_taxa ep USING (species_number)
	LEFT JOIN fwecology.fwecology_data fw ON id.taxon = fw.taxon
);
ALTER TABLE taxa.taxa_trophic_lvl ADD PRIMARY KEY (species_number);

-- grouping -------------------------------------------------------------------
-- convenience ecotoxicological grouping
DROP TABLE IF EXISTS taxa.taxa_group;
CREATE TABLE taxa.taxa_group AS (
	SELECT
		-- TODO include more?
		-- TODO morse sources
		id.species_number,
		id.taxon,
		GREATEST(fw.diatom)::boolean AS diatom,
		GREATEST(fw.invertebrate_macro)::boolean AS invertebrate_macro,
		GREATEST(fw.fish)::boolean AS fish,
		GREATEST(fw.macrophyte)::boolean AS macrophyte,
		GREATEST(fw.phytoplankton)::boolean AS algae
	FROM taxa.taxa_id id
	LEFT JOIN fwecology.fwecology_data fw USING(taxon)
	-- TODO what more
);
ALTER TABLE taxa.taxa_group ADD PRIMARY KEY (species_number);

-- continent ------------------------------------------------------------------
DROP TABLE IF EXISTS taxa.taxa_continent;
CREATE TABLE taxa.taxa_continent AS (
	SELECT
		id.species_number,
		id.taxon,
		GREATEST(gb.africa)::boolean AS africa,
		GREATEST(gb.asia)::boolean AS asia,
		GREATEST(fw.europe, gb.europe)::boolean AS europe,
		GREATEST(gb.north_america)::boolean AS america_north,
		GREATEST(gb.south_america)::boolean AS america_south,
		GREATEST(gb.oceania)::boolean AS oceania
FROM taxa.taxa_id id
LEFT JOIN gbif.gbif_continent gb USING (taxon)
LEFT JOIN fwecology.fwecology_data fw USING(taxon)
);
ALTER TABLE taxa.taxa_continent ADD PRIMARY KEY (species_number);

-- country --------------------------------------------------------------------
-- TODO include countries from freshwaterecology.info here
DROP TABLE IF EXISTS taxa.taxa_country;
CREATE TABLE taxa.taxa_country AS (
	SELECT 
		id.species_number,
		id.taxon,
		GREATEST(gb.ad)::boolean AS ad,
		GREATEST(gb.ae)::boolean AS ae,
		GREATEST(gb.af)::boolean AS af,
		GREATEST(gb.ag)::boolean AS ag,
		GREATEST(gb.ai)::boolean AS ai,
		GREATEST(gb.al)::boolean AS al,
		GREATEST(gb.am)::boolean AS am,
		GREATEST(gb.ao)::boolean AS ao,
		GREATEST(gb.aq)::boolean AS aq,
		GREATEST(gb.ar)::boolean AS ar,
		GREATEST(gb.as)::boolean AS as,
		GREATEST(fw.at, gb.at)::boolean AS at,
		GREATEST(gb.au)::boolean AS au,
		GREATEST(gb.aw)::boolean AS aw,
		GREATEST(gb.ax)::boolean AS ax,
		GREATEST(gb.az)::boolean AS az,
		GREATEST(gb.ba)::boolean AS ba,
		GREATEST(gb.bb)::boolean AS bb,
		GREATEST(gb.bd)::boolean AS bd,
		GREATEST(fw.be, gb.be)::boolean AS be,
		GREATEST(gb.bf)::boolean AS bf,
		GREATEST(fw.bg, gb.bg)::boolean AS bg,
		GREATEST(gb.bh)::boolean AS bh,
		GREATEST(gb.bi)::boolean AS bi,
		GREATEST(gb.bj)::boolean AS bj,
		GREATEST(gb.bl)::boolean AS bl,
		GREATEST(gb.bm)::boolean AS bm,
		GREATEST(gb.bn)::boolean AS bn,
		GREATEST(gb.bo)::boolean AS bo,
		GREATEST(gb.bq)::boolean AS bq,
		GREATEST(gb.br)::boolean AS br,
		GREATEST(gb.bs)::boolean AS bs,
		GREATEST(gb.bt)::boolean AS bt,
		GREATEST(gb.bv)::boolean AS bv,
		GREATEST(gb.bw)::boolean AS bw,
		GREATEST(gb.by)::boolean AS by,
		GREATEST(gb.bz)::boolean AS bz,
		GREATEST(gb.ca)::boolean AS ca,
		GREATEST(gb.cc)::boolean AS cc,
		GREATEST(gb.cd)::boolean AS cd,
		GREATEST(gb.cf)::boolean AS cf,
		GREATEST(gb.cg)::boolean AS cg,
		GREATEST(fw.ch, gb.ch)::boolean AS ch,
		GREATEST(gb.ci)::boolean AS ci,
		GREATEST(gb.ck)::boolean AS ck,
		GREATEST(gb.cl)::boolean AS cl,
		GREATEST(gb.cm)::boolean AS cm,
		GREATEST(gb.cn)::boolean AS cn,
		GREATEST(gb.co)::boolean AS co,
		GREATEST(gb.cr)::boolean AS cr,
		GREATEST(gb.cu)::boolean AS cu,
		GREATEST(gb.cv)::boolean AS cv,
		GREATEST(gb.cw)::boolean AS cw,
		GREATEST(gb.cx)::boolean AS cx,
		GREATEST(gb.cy)::boolean AS cy,
		GREATEST(fw.cz, gb.cz)::boolean AS cz,
		GREATEST(fw.de, gb.de)::boolean AS de,
		GREATEST(gb.dj)::boolean AS dj,
		GREATEST(fw.dk, gb.dk)::boolean AS dk,
		GREATEST(gb.dm)::boolean AS dm,
		GREATEST(gb.do)::boolean AS do,
		GREATEST(gb.dz)::boolean AS dz,
		GREATEST(gb.ec)::boolean AS ec,
		GREATEST(gb.ee)::boolean AS ee,
		GREATEST(gb.eg)::boolean AS eg,
		GREATEST(gb.eh)::boolean AS eh,
		GREATEST(gb.er)::boolean AS er,
		GREATEST(fw.es, gb.es)::boolean AS es,
		GREATEST(gb.et)::boolean AS et,
		GREATEST(fw.eu)::boolean AS eu,
		GREATEST(fw.fi, gb.fi)::boolean AS fi,
		GREATEST(gb.fj)::boolean AS fj,
		GREATEST(gb.fk)::boolean AS fk,
		GREATEST(gb.fm)::boolean AS fm,
		GREATEST(gb.fo)::boolean AS fo,
		GREATEST(fw.fr, gb.fr)::boolean AS fr,
		GREATEST(gb.ga)::boolean AS ga,
		GREATEST(fw.gb, gb.gb)::boolean AS gb,
		GREATEST(gb.gd)::boolean AS gd,
		GREATEST(gb.ge)::boolean AS ge,
		GREATEST(gb.gf)::boolean AS gf,
		GREATEST(gb.gg)::boolean AS gg,
		GREATEST(gb.gh)::boolean AS gh,
		GREATEST(gb.gi)::boolean AS gi,
		GREATEST(gb.gl)::boolean AS gl,
		GREATEST(gb.gm)::boolean AS gm,
		GREATEST(gb.gn)::boolean AS gn,
		GREATEST(gb.gp)::boolean AS gp,
		GREATEST(gb.gq)::boolean AS gq,
		GREATEST(fw.gr, gb.gr)::boolean AS gr,
		GREATEST(gb.gs)::boolean AS gs,
		GREATEST(gb.gt)::boolean AS gt,
		GREATEST(gb.gu)::boolean AS gu,
		GREATEST(gb.gw)::boolean AS gw,
		GREATEST(gb.gy)::boolean AS gy,
		GREATEST(gb.hk)::boolean AS hk,
		GREATEST(gb.hm)::boolean AS hm,
		GREATEST(gb.hn)::boolean AS hn,
		GREATEST(fw.hr, gb.hr)::boolean AS hr,
		GREATEST(gb.ht)::boolean AS ht,
		GREATEST(gb.hu)::boolean AS hu,
		GREATEST(gb.id)::boolean AS id,
		GREATEST(gb.ie)::boolean AS ie,
		GREATEST(gb.il)::boolean AS il,
		GREATEST(gb.im)::boolean AS im,
		GREATEST(gb.in)::boolean AS in,
		GREATEST(gb.io)::boolean AS io,
		GREATEST(gb.iq)::boolean AS iq,
		GREATEST(gb.ir)::boolean AS ir,
		GREATEST(gb.is)::boolean AS is,
		GREATEST(fw.it, gb.it)::boolean AS it,
		GREATEST(gb.je)::boolean AS je,
		GREATEST(gb.jm)::boolean AS jm,
		GREATEST(gb.jo)::boolean AS jo,
		GREATEST(gb.jp)::boolean AS jp,
		GREATEST(gb.ke)::boolean AS ke,
		GREATEST(gb.kg)::boolean AS kg,
		GREATEST(gb.kh)::boolean AS kh,
		GREATEST(gb.ki)::boolean AS ki,
		GREATEST(gb.km)::boolean AS km,
		GREATEST(gb.kn)::boolean AS kn,
		GREATEST(gb.kp)::boolean AS kp,
		GREATEST(gb.kr)::boolean AS kr,
		GREATEST(gb.kw)::boolean AS kw,
		GREATEST(gb.ky)::boolean AS ky,
		GREATEST(gb.kz)::boolean AS kz,
		GREATEST(gb.la)::boolean AS la,
		GREATEST(gb.lb)::boolean AS lb,
		GREATEST(gb.lc)::boolean AS lc,
		GREATEST(gb.li)::boolean AS li,
		GREATEST(gb.lk)::boolean AS lk,
		GREATEST(gb.lr)::boolean AS lr,
		GREATEST(gb.ls)::boolean AS ls,
		GREATEST(fw.lt, gb.lt)::boolean AS lt,
		GREATEST(gb.lu)::boolean AS lu,
		GREATEST(fw.lv, gb.lv)::boolean AS lv,
		GREATEST(gb.ly)::boolean AS ly,
		GREATEST(gb.ma)::boolean AS ma,
		GREATEST(gb.mc)::boolean AS mc,
		GREATEST(gb.md)::boolean AS md,
		GREATEST(gb.me)::boolean AS me,
		GREATEST(gb.mf)::boolean AS mf,
		GREATEST(gb.mg)::boolean AS mg,
		GREATEST(gb.mh)::boolean AS mh,
		GREATEST(gb.mk)::boolean AS mk,
		GREATEST(gb.ml)::boolean AS ml,
		GREATEST(gb.mm)::boolean AS mm,
		GREATEST(gb.mn)::boolean AS mn,
		GREATEST(gb.mo)::boolean AS mo,
		GREATEST(gb.mp)::boolean AS mp,
		GREATEST(gb.mq)::boolean AS mq,
		GREATEST(gb.mr)::boolean AS mr,
		GREATEST(gb.ms)::boolean AS ms,
		GREATEST(gb.mt)::boolean AS mt,
		GREATEST(gb.mu)::boolean AS mu,
		GREATEST(gb.mv)::boolean AS mv,
		GREATEST(gb.mw)::boolean AS mw,
		GREATEST(gb.mx)::boolean AS mx,
		GREATEST(gb.my)::boolean AS my,
		GREATEST(gb.mz)::boolean AS mz,
		GREATEST(gb.na)::boolean AS na,
		GREATEST(gb.nc)::boolean AS nc,
		GREATEST(gb.ne)::boolean AS ne,
		GREATEST(gb.nf)::boolean AS nf,
		GREATEST(gb.ng)::boolean AS ng,
		GREATEST(gb.ni)::boolean AS ni,
		GREATEST(fw.nl, gb.nl)::boolean AS nl,
		GREATEST(fw.no, gb.no)::boolean AS no,
		GREATEST(gb.np)::boolean AS np,
		GREATEST(gb.nr)::boolean AS nr,
		GREATEST(gb.nu)::boolean AS nu,
		GREATEST(gb.nz)::boolean AS nz,
		GREATEST(gb.om)::boolean AS om,
		GREATEST(gb.pa)::boolean AS pa,
		GREATEST(gb.pe)::boolean AS pe,
		GREATEST(gb.pf)::boolean AS pf,
		GREATEST(gb.pg)::boolean AS pg,
		GREATEST(gb.ph)::boolean AS ph,
		GREATEST(gb.pk)::boolean AS pk,
		GREATEST(fw.pl, gb.pl)::boolean AS pl,
		GREATEST(gb.pm)::boolean AS pm,
		GREATEST(gb.pn)::boolean AS pn,
		GREATEST(gb.pr)::boolean AS pr,
		GREATEST(gb.ps)::boolean AS ps,
		GREATEST(fw.pt, gb.pt)::boolean AS pt,
		GREATEST(gb.pw)::boolean AS pw,
		GREATEST(gb.py)::boolean AS py,
		GREATEST(gb.qa)::boolean AS qa,
		GREATEST(gb.re)::boolean AS re,
		GREATEST(fw.ro, gb.ro)::boolean AS ro,
		GREATEST(gb.rs)::boolean AS rs,
		GREATEST(gb.ru)::boolean AS ru,
		GREATEST(gb.rw)::boolean AS rw,
		GREATEST(gb.sa)::boolean AS sa,
		GREATEST(gb.sb)::boolean AS sb,
		GREATEST(gb.sc)::boolean AS sc,
		GREATEST(gb.sd)::boolean AS sd,
		GREATEST(fw.se, gb.se)::boolean AS se,
		GREATEST(gb.sg)::boolean AS sg,
		GREATEST(gb.sh)::boolean AS sh,
		GREATEST(gb.si)::boolean AS si,
		GREATEST(gb.sj)::boolean AS sj,
		GREATEST(fw.sk, gb.sk)::boolean AS sk,
		GREATEST(gb.sl)::boolean AS sl,
		GREATEST(gb.sm)::boolean AS sm,
		GREATEST(gb.sn)::boolean AS sn,
		GREATEST(gb.so)::boolean AS so,
		GREATEST(gb.sr)::boolean AS sr,
		GREATEST(gb.ss)::boolean AS ss,
		GREATEST(gb.st)::boolean AS st,
		GREATEST(gb.sv)::boolean AS sv,
		GREATEST(gb.sx)::boolean AS sx,
		GREATEST(gb.sy)::boolean AS sy,
		GREATEST(gb.sz)::boolean AS sz,
		GREATEST(gb.tc)::boolean AS tc,
		GREATEST(gb.td)::boolean AS td,
		GREATEST(gb.tf)::boolean AS tf,
		GREATEST(gb.tg)::boolean AS tg,
		GREATEST(gb.th)::boolean AS th,
		GREATEST(gb.tj)::boolean AS tj,
		GREATEST(gb.tk)::boolean AS tk,
		GREATEST(gb.tl)::boolean AS tl,
		GREATEST(gb.tm)::boolean AS tm,
		GREATEST(gb.tn)::boolean AS tn,
		GREATEST(gb.to)::boolean AS to,
		GREATEST(fw.tr, gb.tr)::boolean AS tr,
		GREATEST(gb.tt)::boolean AS tt,
		GREATEST(gb.tv)::boolean AS tv,
		GREATEST(gb.tw)::boolean AS tw,
		GREATEST(gb.tz)::boolean AS tz,
		GREATEST(fw.ua, gb.ua)::boolean AS ua,
		GREATEST(gb.ug)::boolean AS ug,
		GREATEST(gb.um)::boolean AS um,
		GREATEST(gb.us)::boolean AS us,
		GREATEST(gb.uy)::boolean AS uy,
		GREATEST(gb.uz)::boolean AS uz,
		GREATEST(gb.vc)::boolean AS vc,
		GREATEST(gb.ve)::boolean AS ve,
		GREATEST(gb.vg)::boolean AS vg,
		GREATEST(gb.vi)::boolean AS vi,
		GREATEST(gb.vn)::boolean AS vn,
		GREATEST(gb.vu)::boolean AS vu,
		GREATEST(gb.wf)::boolean AS wf,
		GREATEST(gb.ws)::boolean AS ws,
		GREATEST(gb.xk)::boolean AS xk,
		GREATEST(gb.ye)::boolean AS ye,
		GREATEST(gb.yt)::boolean AS yt,
		GREATEST(gb.za)::boolean AS za,
		GREATEST(gb.zm)::boolean AS zm,
		GREATEST(gb.zw)::boolean AS zw,
		GREATEST(gb.zz)::boolean AS zz
	FROM taxa.taxa_id id
	LEFT JOIN gbif.gbif_country_code gb USING (taxon)
	LEFT JOIN fwecology.fwecology_data fw USING (taxon)
);
ALTER TABLE taxa.taxa_country ADD PRIMARY KEY (species_number);
