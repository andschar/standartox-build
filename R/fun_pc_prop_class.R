# script to download CHEBI data via pubchem
# TODO main problem data.tree structure


# setup -------------------------------------------------------------------
require(httr)
require(jsonlite)
require(data.tree)


# classification patterns -------------------------------------------------
subs_pattern = function(node = NULL, pattern = NULL) {
  # TODO include recursion!
  # https://stackoverflow.com/questions/45225671/aggregating-values-on-a-data-tree-with-r
  if (is.null(node)) {
    stop('No node provided.')
  }
  if (is.null(pattern)) {
    stop('No pattern provided.')
  }
  
  idx = as.character(which(sapply(node, function(x) x$Information$Name) == pattern))
  ids = node[[idx]]$Information$ChildID
  idx_chi = as.character(which(sapply(node, function(x) x$NodeID) %in% ids))
  out = sapply(idx_chi, function(x) node[[x]]$Information$Name)
  
  return(out)
}


# prop class function -----------------------------------------------------
pc_prop_class = function(cid, properties = NULL, src = c('chebi', 'cameo'), verbose = TRUE, ...) {
  
  src = match.arg(src, c('chebi', 'cameo'))
  # query -------------------------------------------------------------------
  qurl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/classification/JSON?classification_type=simple'
  #cid = c(1983, 5743) # debuging

  res_l <- list()
  save_l = list()
  for (i in seq_along(cid)) {
    
    id = cid[i]
    post = POST(qurl, body = list("cid" = id))
    message('Querying CID: ', id)
    Sys.sleep(0.2)
    cont_json = try(content(post, type = 'text', encoding = 'UTF-8'), silent = FALSE)
    
    save_l[[i]] = cont_json
    names(save_l)[i] = id
    
    if (inherits(cont_json, "try-error")) {
      warning('Problem with web service encountered... Returning NA.')
      return(NA)
    }
    cont = fromJSON(cont_json, simplifyDataFrame = FALSE)
    if (names(cont) == 'Fault') {
      warning(cont$Fault$Details, '. Returning NA.')
      return(NA)
    }
    
    # output ------------------------------------------------------------------
    if (src == 'chebi') {
      # out = sapply(ch_node, function(x) x$Information$Name)
      # data.tree
      cont_tree = as.Node(cont)
      ch_node = cont_tree$Hierarchies$Hierarchy$`3`$Node
      # ChEBI
      # idx_chebi = which(sapply(cont_l, function(x) x$SourceName == 'ChEBI'))
      # chebi = cont_l[[idx_chebi]]
      # ch_node = chebi$Node
      
      out = list(
        bio_role = subs_pattern(ch_node, 'biological role'),
        chem_role = subs_pattern(ch_node, 'chemical role')
        # application = subs_pattern(ch_node, 'application')
      )
    }
    if (src == 'cameo') {
      # subset list according to data source
      cont_l = cont$Hierarchies$Hierarchy
      # CAMEO
      idx_cameo = which(sapply(cont_l, function(x) x$SourceName == 'CAMEO Chemicals'))
      cameo = cont_l[[idx_cameo]]
      ca_node = cameo$Node
      
      out = sapply(ca_node, function(x) x$Information$Name)
    }
    res_l[[i]] = out
    names(res_l)[i] = id
  }
  
  saveRDS(save_l, file.path(cachedir, 'pc_classification_l.rds'))
  message('Up tp now only unstructured content is returned')
  return(res_l)
}


# approach to extract tree nodes ------------------------------------------
# TODO implement this
# TODO improve funvtion
# TODO enable recursion!
# require(data.tree)
# cont_tree = as.Node(cont)
# chebi_node = cont_tree$Hierarchies$Hierarchy$`3`$Node
# 
# #node = chebi_node; pattern = 'chemical role'
# 
# 
# subs_pattern(chebi_node, 'biochemical role')





# try to retrieve tree information ----------------------------------------
# (2) 
# test = as.Node(cont, mode = 'simple')
# test$fieldsAll
# print(test, 'Name', limit = 3)
# 
# print(test, 'Hierarchies', 'Hierarchy')
# 
# test$Climb(name = 'Name')
# 
# 
# df = as.data.frame(test)
# 
# # heavy construct ---------------------------------------------------------
# # get index of 'role' list element
# idx_role_node = grep('^role$', sapply(ch_node, function(x) x$Information$Name), ignore.case = TRUE)
# # retrieve child nodes
# child_nodes = ch_node[[idx_role_node]]$Information$ChildID
# # retriece child indices
# idx_roles = which(sapply(ch_node, function(x) x$NodeID) %in% child_nodes)
# names(idx_roles) = sapply(ch_node[idx_roles], function(x) x$Information$Name)
# # retrieve child node indices
# child_nodes2 = sapply(ch_node[idx_roles], function(x) x$Information$ChildID)
# idx_bio = which(sapply(ch_node, function(x) x$NodeID) %in% child_nodes2[[1]])
# idx_app = which(sapply(ch_node, function(x) x$NodeID) %in% child_nodes2[[2]])
# idx_che = which(sapply(ch_node, function(x) x$NodeID) %in% child_nodes2[[3]])
# sapply(ch_node[idx_bio], function(x) x$Information$Name)
# sapply(ch_node[idx_app], function(x) x$Information$Name)
# sapply(ch_node[idx_che], function(x) x$Information$Name)
# 
# 
# # JSON approach -----------------------------------------------------------
# cont2 = fromJSON(cont_json, simplifyDataFrame = FALSE)
# chebi_tree2 = as.Node(cont, mode = 'explicit')
# chebi_tree2$fieldsAll
# chebi_tree2$pathString = paste('root',
#                                chebi_tree2$Hierachies,
#                                chebi_tree2$Hierachy,
#                                chebi_tree2$Node,
#                                chebi_tree2$Information,
#                                chebi_tree2$Name,
#                                sep = '/')
# 
# cont2$Hierarchies$Hierarchy[[1]]$Node[[4]]$Information$Name
# print(chebi_tree2, 'Name', limit = 3)
# 
# 
# ch_node[[81]]$Information$Name
# 
# ch_tree = as.Node(ch_node)
# 
# ch_tree[[4]]
# 
# 
# 
# 
# # tidygraph ---------------------------------------------------------------
# require(tidygraph)
# cont = fromJSON(cont_json, simplifyDataFrame = FALSE)
# cont_gr = as_tbl_graph(cont, nodes = Information, edges = Node)
# class(chebi)
# 
# as_tbl_graph.list
# 
# cont$Hierarchies$Hierarchy[[1]]$
# 
# 
# 
# 
# 
# 
# 
# 
#   
# names(ch_tree)
# 
# 
# # intermediate
# save = chebi
# 
# 
# chebi$Node[[1]]$ParentID
# 
# # (2)
# chebi$pathString = paste('Chebi Onthology',
#                          chebi$Node)
# 
# 
# 
# print(chebi, limit = 10)
# chebi$Node
# 
# 
# chebi$Node[[1]]$Information$Name
# 
# chebi_tree = as.Node(chebi, mode = 'simple')
# print(chebi_tree, 'Name')
# 
# FromListSimple(chebi, nameName = 'Name')
# FromListSimple(chebi, nodeName = 'role')
# 
# Cumulate(chebi_tree,
#          attribute = 'biological role',
#          print)
# 
# print(chebi_tree, limit = 100)
# 
# grep('role', sapply(chebi$Node, function(x) x$Information$Name))
# 
# 
# as.Node
# print(chebi_tree, 'Name')
# class(ch_node)
# 
# chebi_tree$fieldsAll
# 
# print(chebi_tree, 'Name')
# chebi_tree$Climb('Name')
