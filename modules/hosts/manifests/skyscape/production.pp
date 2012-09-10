class hosts::skyscape::production {
  # These are real hosts (1-1 mapping between Host and Service)
  # Anything that ends .cluster is maintained for backwards compatibility with EC2
  #Management VDC machines
  host { 'puppet-1.management.production'  : ip => '10.0.0.2', host_aliases => [ 'puppet-1', 'puppet' ] }
  host { 'jenkins-1.management.production' : ip => '10.0.0.3' }

  #Router VDC machines
  host { 'cache-1.router.production'        : ip => '10.1.0.2', host_aliases => ['cache-1', 'cache.cluster', 'router.cluster'] }# This host aliases need to point to the Load balancer when it is in
  host { 'cache-2.router.production'        : ip => '10.1.0.3' }
  host { 'cache-3.router.production'        : ip => '10.1.0.4' }
  host { 'router-mongo-1.router.production' : ip => '10.1.0.5' }

  #Frontend VDC machines
  host { 'frontend-1.frontend.production'  : ip => '10.2.0.2' }
  host { 'frontend-2.frontend.production'  : ip => '10.2.0.3' }
  host { 'frontend-3.frontend.production'  : ip => '10.2.0.4' }

  #Backend VDC machines
  host { 'backend-1.backend.production'         : ip => '10.3.0.2', host_aliases => [ 'backend-1', 'signon.production.alphagov.co.uk'] }
  host { 'backend-2.backend.production'         : ip => '10.3.0.3' }
  host { 'backend-3.backend.production'         : ip => '10.3.0.4' }
  host { 'support-1.backend.production'         : ip => '10.3.0.5' , host_aliases => [ 'support-1', 'support.cluster']}
  host { 'mongo-1.backend.production'           : ip => '10.3.0.6', host_aliases  => [ 'mongo.backend.production', 'mongodb.cluster' ] }
  host { 'mongo-2.backend.production'           : ip => '10.3.0.7' }
  host { 'mongo-3.backend.production'           : ip => '10.3.0.8' }
  host { 'mysql-master-1.backend.production'    : ip => '10.3.10.0', host_aliases => [ 'mysql-master-1', 'mysql.backend.production' ]  }
}
