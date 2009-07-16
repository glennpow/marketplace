function update_feature_comparable(select, feature_id) {
  switch(select.options[select.selectedIndex].value) {
    case 'equals', 'greater_than':
      $('features_' + feature_id + '_low').enable();
      $(feature_id + '_low_span').show();
      $(feature_id + '_dash_span').hide();
      $(feature_id + '_high_span').hide();
      $('features_' + feature_id + '_high').disable();
      break;
    case 'less_than':
      $(feature_id + '_low_span').hide();
      $('features_' + feature_id + '_low').disable();
      $(feature_id + '_dash_span').hide();
      $('features_' + feature_id + '_high').enable();
      $(feature_id + '_high_span').show();
      break;
    case 'between':
      $('features_' + feature_id + '_low').enable();
      $(feature_id + '_low_span').show();
      $(feature_id + '_dash_span').show();
      $('features_' + feature_id + '_high').enable();
      $(feature_id + '_high_span').show();
      break;
  }
}