if (doc.containsKey('_type')) {
  type=doc['_type'].value;
  return ( type in weights ) ? weights[ type ] : 0 
} else { 
  return 0 
}