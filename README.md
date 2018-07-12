# etox-data base

## setup

## input

## query chemical properties

2 kind of queries
1) chemical information queries
  - cas/casnr
  - common name
  - InchiKey
  - psm type
  - chemical group? after PAN (what's the best source)
    - PAN
    - FRAC (insecticides)
    
    !CONTINUE HERE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  IN LOAD:  replace cas_l with a data.frame containing this information before quering EPA!

### PubChem query
important varaibles: NULL
- XLogP (i.e. logKoc)
- Exact mass
- TPSA (Topological polar surface area = surface sum over all polar atoms - prim O and N - used freq in medicinal chemistry (>140angstroms -> poor at penetr cells))
- Complexity?

### PAN query
important variables: 
- use type
- chemical class
- POPs
- Ground water contaminant
- Dirty Dozen
- Water solubility (Avg, mg/L)

### AW query
important variables:
- activity = psm_type
- subactivity = finer diferentiation (eg. pyrethroids)
- (cname)

### PHYSPROP Database
- Atmospheric OH RAte Constant
- Boiling point
- Henry's Law Constant
- Log P (octanol water)
- Melting point
- Water solubility

## query tox data

### EPA query
EPA needs CASNR!

### TODO!
#### Solubility check

## cleaning

## analysis

## writing