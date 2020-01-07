-- scripts to aggregate organism habitat and occurrence information

-- habitat --------------------------------------------------------------------
DROP TABLE IF EXISTS taxa.habitat;
CREATE TABLE taxa.habitat AS (
	SELECT epa.taxon,
		GREATEST(worms_genus.brack, worms_species.brack, epa_habi.brack)::integer::boolean AS brack,
		GREATEST(worms_genus.fresh, worms_species.fresh, epa_habi.fresh)::integer::boolean AS fresh,
		GREATEST(worms_genus.marin, worms_species.marin, epa_habi.marin)::integer::boolean AS marin,
		GREATEST(worms_genus.terre, worms_species.terre, epa_habi.terre)::integer::boolean AS terre
	FROM taxa.epa
	LEFT JOIN taxa.worms_genus ON epa.taxon = worms_genus.taxon
	LEFT JOIN taxa.worms_species ON epa.taxon = worms_species.taxon
	LEFT JOIN taxa.epa_habi ON epa.taxon = epa_habi.taxon
);

-- continent ------------------------------------------------------------------
DROP TABLE IF EXISTS taxa.continent;
CREATE TABLE taxa.continent AS (
	SELECT epa.taxon,
		GREATEST(continent.africa) AS africa,
		GREATEST(continent.asia) AS asia,
		GREATEST(continent.europe) AS europe,
		GREATEST(continent.north_america) AS america_north,
		GREATEST(continent.south_america) AS america_south,
		GREATEST(continent.oceania) AS oceania
FROM taxa.epa
LEFT JOIN gbif.continent ON continent.taxon = epa.taxon
);

-- country --------------------------------------------------------------------
DROP TABLE IF EXISTS taxa.country;
CREATE TABLE taxa.country AS (
	SELECT epa.taxon,
		GREATEST(country_code.ad) AS ad,
		GREATEST(country_code.ae) AS ae,
		GREATEST(country_code.af) AS af,
		GREATEST(country_code.ag) AS ag,
		GREATEST(country_code.ai) AS ai,
		GREATEST(country_code.al) AS al,
		GREATEST(country_code.am) AS am,
		GREATEST(country_code.ao) AS ao,
		GREATEST(country_code.aq) AS aq,
		GREATEST(country_code.ar) AS ar,
		GREATEST(country_code.as) AS as,
		GREATEST(country_code.at) AS at,
		GREATEST(country_code.au) AS au,
		GREATEST(country_code.aw) AS aw,
		GREATEST(country_code.ax) AS ax,
		GREATEST(country_code.az) AS az,
		GREATEST(country_code.ba) AS ba,
		GREATEST(country_code.bb) AS bb,
		GREATEST(country_code.bd) AS bd,
		GREATEST(country_code.be) AS be,
		GREATEST(country_code.bf) AS bf,
		GREATEST(country_code.bg) AS bg,
		GREATEST(country_code.bh) AS bh,
		GREATEST(country_code.bi) AS bi,
		GREATEST(country_code.bj) AS bj,
		GREATEST(country_code.bl) AS bl,
		GREATEST(country_code.bm) AS bm,
		GREATEST(country_code.bn) AS bn,
		GREATEST(country_code.bo) AS bo,
		GREATEST(country_code.bq) AS bq,
		GREATEST(country_code.br) AS br,
		GREATEST(country_code.bs) AS bs,
		GREATEST(country_code.bt) AS bt,
		GREATEST(country_code.bv) AS bv,
		GREATEST(country_code.bw) AS bw,
		GREATEST(country_code.by) AS by,
		GREATEST(country_code.bz) AS bz,
		GREATEST(country_code.ca) AS ca,
		GREATEST(country_code.cc) AS cc,
		GREATEST(country_code.cd) AS cd,
		GREATEST(country_code.cf) AS cf,
		GREATEST(country_code.cg) AS cg,
		GREATEST(country_code.ch) AS ch,
		GREATEST(country_code.ci) AS ci,
		GREATEST(country_code.ck) AS ck,
		GREATEST(country_code.cl) AS cl,
		GREATEST(country_code.cm) AS cm,
		GREATEST(country_code.cn) AS cn,
		GREATEST(country_code.co) AS co,
		GREATEST(country_code.cr) AS cr,
		GREATEST(country_code.cu) AS cu,
		GREATEST(country_code.cv) AS cv,
		GREATEST(country_code.cw) AS cw,
		GREATEST(country_code.cx) AS cx,
		GREATEST(country_code.cy) AS cy,
		GREATEST(country_code.cz) AS cz,
		GREATEST(country_code.de) AS de,
		GREATEST(country_code.dj) AS dj,
		GREATEST(country_code.dk) AS dk,
		GREATEST(country_code.dm) AS dm,
		GREATEST(country_code.do) AS do,
		GREATEST(country_code.dz) AS dz,
		GREATEST(country_code.ec) AS ec,
		GREATEST(country_code.ee) AS ee,
		GREATEST(country_code.eg) AS eg,
		GREATEST(country_code.eh) AS eh,
		GREATEST(country_code.er) AS er,
		GREATEST(country_code.es) AS es,
		GREATEST(country_code.et) AS et,
		GREATEST(country_code.fi) AS fi,
		GREATEST(country_code.fj) AS fj,
		GREATEST(country_code.fk) AS fk,
		GREATEST(country_code.fm) AS fm,
		GREATEST(country_code.fo) AS fo,
		GREATEST(country_code.fr) AS fr,
		GREATEST(country_code.ga) AS ga,
		GREATEST(country_code.gb) AS gb,
		GREATEST(country_code.gd) AS gd,
		GREATEST(country_code.ge) AS ge,
		GREATEST(country_code.gf) AS gf,
		GREATEST(country_code.gg) AS gg,
		GREATEST(country_code.gh) AS gh,
		GREATEST(country_code.gi) AS gi,
		GREATEST(country_code.gl) AS gl,
		GREATEST(country_code.gm) AS gm,
		GREATEST(country_code.gn) AS gn,
		GREATEST(country_code.gp) AS gp,
		GREATEST(country_code.gq) AS gq,
		GREATEST(country_code.gr) AS gr,
		GREATEST(country_code.gs) AS gs,
		GREATEST(country_code.gt) AS gt,
		GREATEST(country_code.gu) AS gu,
		GREATEST(country_code.gw) AS gw,
		GREATEST(country_code.gy) AS gy,
		GREATEST(country_code.hk) AS hk,
		GREATEST(country_code.hm) AS hm,
		GREATEST(country_code.hn) AS hn,
		GREATEST(country_code.hr) AS hr,
		GREATEST(country_code.ht) AS ht,
		GREATEST(country_code.hu) AS hu,
		GREATEST(country_code.id) AS id,
		GREATEST(country_code.ie) AS ie,
		GREATEST(country_code.il) AS il,
		GREATEST(country_code.im) AS im,
		GREATEST(country_code.in) AS in,
		GREATEST(country_code.io) AS io,
		GREATEST(country_code.iq) AS iq,
		GREATEST(country_code.ir) AS ir,
		GREATEST(country_code.is) AS is,
		GREATEST(country_code.it) AS it,
		GREATEST(country_code.je) AS je,
		GREATEST(country_code.jm) AS jm,
		GREATEST(country_code.jo) AS jo,
		GREATEST(country_code.jp) AS jp,
		GREATEST(country_code.ke) AS ke,
		GREATEST(country_code.kg) AS kg,
		GREATEST(country_code.kh) AS kh,
		GREATEST(country_code.ki) AS ki,
		GREATEST(country_code.km) AS km,
		GREATEST(country_code.kn) AS kn,
		GREATEST(country_code.kp) AS kp,
		GREATEST(country_code.kr) AS kr,
		GREATEST(country_code.kw) AS kw,
		GREATEST(country_code.ky) AS ky,
		GREATEST(country_code.kz) AS kz,
		GREATEST(country_code.la) AS la,
		GREATEST(country_code.lb) AS lb,
		GREATEST(country_code.lc) AS lc,
		GREATEST(country_code.li) AS li,
		GREATEST(country_code.lk) AS lk,
		GREATEST(country_code.lr) AS lr,
		GREATEST(country_code.ls) AS ls,
		GREATEST(country_code.lt) AS lt,
		GREATEST(country_code.lu) AS lu,
		GREATEST(country_code.lv) AS lv,
		GREATEST(country_code.ly) AS ly,
		GREATEST(country_code.ma) AS ma,
		GREATEST(country_code.mc) AS mc,
		GREATEST(country_code.md) AS md,
		GREATEST(country_code.me) AS me,
		GREATEST(country_code.mf) AS mf,
		GREATEST(country_code.mg) AS mg,
		GREATEST(country_code.mh) AS mh,
		GREATEST(country_code.mk) AS mk,
		GREATEST(country_code.ml) AS ml,
		GREATEST(country_code.mm) AS mm,
		GREATEST(country_code.mn) AS mn,
		GREATEST(country_code.mo) AS mo,
		GREATEST(country_code.mp) AS mp,
		GREATEST(country_code.mq) AS mq,
		GREATEST(country_code.mr) AS mr,
		GREATEST(country_code.ms) AS ms,
		GREATEST(country_code.mt) AS mt,
		GREATEST(country_code.mu) AS mu,
		GREATEST(country_code.mv) AS mv,
		GREATEST(country_code.mw) AS mw,
		GREATEST(country_code.mx) AS mx,
		GREATEST(country_code.my) AS my,
		GREATEST(country_code.mz) AS mz,
		GREATEST(country_code.na) AS na,
		GREATEST(country_code.nc) AS nc,
		GREATEST(country_code.ne) AS ne,
		GREATEST(country_code.nf) AS nf,
		GREATEST(country_code.ng) AS ng,
		GREATEST(country_code.ni) AS ni,
		GREATEST(country_code.nl) AS nl,
		GREATEST(country_code.no) AS no,
		GREATEST(country_code.np) AS np,
		GREATEST(country_code.nr) AS nr,
		GREATEST(country_code.nu) AS nu,
		GREATEST(country_code.nz) AS nz,
		GREATEST(country_code.om) AS om,
		GREATEST(country_code.pa) AS pa,
		GREATEST(country_code.pe) AS pe,
		GREATEST(country_code.pf) AS pf,
		GREATEST(country_code.pg) AS pg,
		GREATEST(country_code.ph) AS ph,
		GREATEST(country_code.pk) AS pk,
		GREATEST(country_code.pl) AS pl,
		GREATEST(country_code.pm) AS pm,
		GREATEST(country_code.pn) AS pn,
		GREATEST(country_code.pr) AS pr,
		GREATEST(country_code.ps) AS ps,
		GREATEST(country_code.pt) AS pt,
		GREATEST(country_code.pw) AS pw,
		GREATEST(country_code.py) AS py,
		GREATEST(country_code.qa) AS qa,
		GREATEST(country_code.re) AS re,
		GREATEST(country_code.ro) AS ro,
		GREATEST(country_code.rs) AS rs,
		GREATEST(country_code.ru) AS ru,
		GREATEST(country_code.rw) AS rw,
		GREATEST(country_code.sa) AS sa,
		GREATEST(country_code.sb) AS sb,
		GREATEST(country_code.sc) AS sc,
		GREATEST(country_code.sd) AS sd,
		GREATEST(country_code.se) AS se,
		GREATEST(country_code.sg) AS sg,
		GREATEST(country_code.sh) AS sh,
		GREATEST(country_code.si) AS si,
		GREATEST(country_code.sj) AS sj,
		GREATEST(country_code.sk) AS sk,
		GREATEST(country_code.sl) AS sl,
		GREATEST(country_code.sm) AS sm,
		GREATEST(country_code.sn) AS sn,
		GREATEST(country_code.so) AS so,
		GREATEST(country_code.sr) AS sr,
		GREATEST(country_code.ss) AS ss,
		GREATEST(country_code.st) AS st,
		GREATEST(country_code.sv) AS sv,
		GREATEST(country_code.sx) AS sx,
		GREATEST(country_code.sy) AS sy,
		GREATEST(country_code.sz) AS sz,
		GREATEST(country_code.tc) AS tc,
		GREATEST(country_code.td) AS td,
		GREATEST(country_code.tf) AS tf,
		GREATEST(country_code.tg) AS tg,
		GREATEST(country_code.th) AS th,
		GREATEST(country_code.tj) AS tj,
		GREATEST(country_code.tk) AS tk,
		GREATEST(country_code.tl) AS tl,
		GREATEST(country_code.tm) AS tm,
		GREATEST(country_code.tn) AS tn,
		GREATEST(country_code.to) AS to,
		GREATEST(country_code.tr) AS tr,
		GREATEST(country_code.tt) AS tt,
		GREATEST(country_code.tv) AS tv,
		GREATEST(country_code.tw) AS tw,
		GREATEST(country_code.tz) AS tz,
		GREATEST(country_code.ua) AS ua,
		GREATEST(country_code.ug) AS ug,
		GREATEST(country_code.um) AS um,
		GREATEST(country_code.us) AS us,
		GREATEST(country_code.uy) AS uy,
		GREATEST(country_code.uz) AS uz,
		GREATEST(country_code.vc) AS vc,
		GREATEST(country_code.ve) AS ve,
		GREATEST(country_code.vg) AS vg,
		GREATEST(country_code.vi) AS vi,
		GREATEST(country_code.vn) AS vn,
		GREATEST(country_code.vu) AS vu,
		GREATEST(country_code.wf) AS wf,
		GREATEST(country_code.ws) AS ws,
		GREATEST(country_code.xk) AS xk,
		GREATEST(country_code.ye) AS ye,
		GREATEST(country_code.yt) AS yt,
		GREATEST(country_code.za) AS za,
		GREATEST(country_code.zm) AS zm,
		GREATEST(country_code.zw) AS zw,
		GREATEST(country_code.zz) AS zz
	FROM taxa.epa
	LEFT JOIN gbif.country_code ON epa.taxon = country_code.taxon
);




