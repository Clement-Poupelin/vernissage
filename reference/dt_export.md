# Interactive table with export buttons

A [`DT::datatable()`](https://rdrr.io/pkg/DT/man/datatable.html) with
column filters and CSV / Excel buttons.

## Usage

``` r
dt_export(df, caption = NULL, page_length = 10, digits = NULL)
```

## Arguments

- df:

  A data frame.

- caption:

  Optional caption.

- page_length:

  Rows per page.

- digits:

  Optional number of significant digits of the double columns.

## Value

An htmlwidget.

## Examples

``` r
dt_export(na_summary(cohort_sim, list(All = names(cohort_sim))))

{"x":{"filter":"top","vertical":false,"filterHTML":"<tr>\n  <td data-type=\"character\" style=\"vertical-align: top;\">\n    <div class=\"form-group has-feedback\" style=\"margin-bottom: auto;\">\n      <input type=\"search\" placeholder=\"All\" class=\"form-control\" style=\"width: 100%;\" disabled=\"\"/>\n      <span class=\"glyphicon glyphicon-remove-circle form-control-feedback\"><\/span>\n    <\/div>\n  <\/td>\n  <td data-type=\"character\" style=\"vertical-align: top;\">\n    <div class=\"form-group has-feedback\" style=\"margin-bottom: auto;\">\n      <input type=\"search\" placeholder=\"All\" class=\"form-control\" style=\"width: 100%;\"/>\n      <span class=\"glyphicon glyphicon-remove-circle form-control-feedback\"><\/span>\n    <\/div>\n  <\/td>\n  <td data-type=\"character\" style=\"vertical-align: top;\">\n    <div class=\"form-group has-feedback\" style=\"margin-bottom: auto;\">\n      <input type=\"search\" placeholder=\"All\" class=\"form-control\" style=\"width: 100%;\"/>\n      <span class=\"glyphicon glyphicon-remove-circle form-control-feedback\"><\/span>\n    <\/div>\n  <\/td>\n  <td data-type=\"integer\" style=\"vertical-align: top;\">\n    <div class=\"form-group has-feedback\" style=\"margin-bottom: auto;\">\n      <input type=\"search\" placeholder=\"All\" class=\"form-control\" style=\"width: 100%;\"/>\n      <span class=\"glyphicon glyphicon-remove-circle form-control-feedback\"><\/span>\n    <\/div>\n    <div style=\"display: none;position: absolute;width: 200px;opacity: 1\">\n      <div data-min=\"0\" data-max=\"14\"><\/div>\n      <span style=\"float: left;\"><\/span>\n      <span style=\"float: right;\"><\/span>\n    <\/div>\n  <\/td>\n  <td data-type=\"number\" style=\"vertical-align: top;\">\n    <div class=\"form-group has-feedback\" style=\"margin-bottom: auto;\">\n      <input type=\"search\" placeholder=\"All\" class=\"form-control\" style=\"width: 100%;\"/>\n      <span class=\"glyphicon glyphicon-remove-circle form-control-feedback\"><\/span>\n    <\/div>\n    <div style=\"display: none;position: absolute;width: 200px;opacity: 1\">\n      <div data-min=\"0\" data-max=\"11.7\" data-scale=\"1\"><\/div>\n      <span style=\"float: left;\"><\/span>\n      <span style=\"float: right;\"><\/span>\n    <\/div>\n  <\/td>\n<\/tr>","extensions":["Buttons"],"data":[["All","All","All","All","All","All","All","All","All","All","All","All","All","All","All","All","All","All","All","All","All"],["MOCA_V3","NFL_V3","IL6_V3","CRP_V3","UPDRS_V3","FALL_V3","PUT_L_V3","PUT_R_V3","PUT_R_V0","CRP_V0","BMI","ID","GROUP","SEX","AGE","NFL_V0","IL6_V0","MOCA_V0","UPDRS_V0","FALL_V0","PUT_L_V0"],["MOCA_V3","NFL_V3","IL6_V3","CRP_V3","UPDRS_V3","FALL_V3","PUT_L_V3","PUT_R_V3","PUT_R_V0","CRP_V0","BMI","ID","GROUP","SEX","AGE","NFL_V0","IL6_V0","MOCA_V0","UPDRS_V0","FALL_V0","PUT_L_V0"],[14,13,10,10,10,10,10,10,6,5,4,0,0,0,0,0,0,0,0,0,0],[11.7,10.8,8.300000000000001,8.300000000000001,8.300000000000001,8.300000000000001,8.300000000000001,8.300000000000001,5,4.2,3.3,0,0,0,0,0,0,0,0,0,0]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>Block<\/th>\n      <th>Variable<\/th>\n      <th>Label<\/th>\n      <th>N_missing<\/th>\n      <th>Pct_missing<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"Bfrtip","buttons":["csv","excel"],"pageLength":10,"scrollX":true,"columnDefs":[{"className":"dt-right","targets":[3,4]},{"name":"Block","targets":0},{"name":"Variable","targets":1},{"name":"Label","targets":2},{"name":"N_missing","targets":3},{"name":"Pct_missing","targets":4}],"order":[],"autoWidth":false,"orderClasses":false,"orderCellsTop":true}},"evals":[],"jsHooks":[]}
```
