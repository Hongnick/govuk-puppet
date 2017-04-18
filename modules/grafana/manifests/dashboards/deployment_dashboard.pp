# == Define: grafana::dashboards::deployment_dashboard
#
# Automate the creation of app specific deployment Grafana dashboards
#
# === Parameters
#
# [*app_name*]
#   The dashboard application identifier name. This matches the name of the
#   deployed application
#
# [*docs_name*]
#   The dashboard application repository used for linking to the documentation
#   page for the application
#
# [*dashboard_directory*]
#   The directory where the Grafana config json files are created
#
# [*app_domain*]
#   The suffix that applications use for their domain names
#
# [*has_workers*]
#   Whether the application uses workers
#
# [*has_controller_data*]
#   Whether the application has Kibana data which is broken down by Rails
#   controller
#
define grafana::dashboards::deployment_dashboard (
  $app_name = $title,
  $docs_name = $title,
  $dashboard_directory = undef,
  $app_domain = undef,
  $has_workers = false,
  $has_controller_data = false,
) {
  if $has_workers {
    $worker_row = [['worker_failures', 'worker_successes']]
  } else {
    $worker_row = []
  }

  if $has_controller_data {
    $errors_by_controller_row = [['errors_by_controller_action']]
    $response_times_by_controller_row = [['response_times_by_controller']]
  } else {
    $errors_by_controller_row = []
    $response_times_by_controller_row = []
  }

  $panel_partials = concat(
    [
      ['processor_count', '5xx_rate'],
      ['error_deploy_counts', 'recent_500_count', 'period_500_count', 'links']
    ],
    $worker_row,
    $errors_by_controller_row,
    $response_times_by_controller_row
  )

  file {
    "${dashboard_directory}/deployment_${app_name}.json": content => template('grafana/dashboards/deployment_dashboard_template.json.erb');
  }
}
