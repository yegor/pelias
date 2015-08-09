if (doc.containsKey('_type')) { 
  return _score * (doc['_type'].value == 'admin0' ? 50 : 1);
} else {
  return _score
}