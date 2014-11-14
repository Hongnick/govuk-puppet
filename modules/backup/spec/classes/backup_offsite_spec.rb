require_relative '../../../../spec_helper'

describe 'backup::offsite', :type => :class do
  let(:default_params) {{
    :dest_host     => 'unused',
    :dest_host_key => 'unused',
    :jobs          => {
      'hungry' => {
        'sources'     => ['/srv/strawberry', '/srv/apple'],
        'destination' => 'rsync://backup.example.com//srv/backup',
        'hour'        => 1,
        'minute'      => 0,
        'gpg_key_id'  => '',
      },
      'caterpillar' => {
        'sources'     => '/srv/orange',
        'destination' => 'rsync://backup.example.com//srv/backup',
        'hour'        => 1,
        'hour'        => 2,
        'minute'      => 30,
      },
    },
  }}

  describe 'jobs' do
    let(:params) { default_params }

    it { should contain_backup__offsite__job('hungry').with(
      :sources     => ['/srv/strawberry', '/srv/apple'],
      :destination => 'rsync://backup.example.com//srv/backup',
      :hour        => '1',
      :minute      => '0',
      :gpg_key_id  => '',
    )}
    it { should contain_backup__offsite__job('caterpillar').with(
      :sources     => '/srv/orange',
      :destination => 'rsync://backup.example.com//srv/backup',
      :hour        => '2',
      :minute      => '30',
    )}
  end

  describe 'enable' do
    context 'false (default)' do
      let(:params) { default_params }

      it { should contain_backup__offsite__job('hungry').with(
        :ensure => 'absent',
      )}
      it { should contain_backup__offsite__job('caterpillar').with(
        :ensure => 'absent',
      )}
    end

    context 'true' do
      let(:params) { default_params.merge({
        :enable => true,
      })}

      it { should contain_backup__offsite__job('hungry').with(
        :ensure => 'present',
      )}
      it { should contain_backup__offsite__job('caterpillar').with(
        :ensure => 'present',
      )}
    end
  end

  describe 'dest_host_key' do
    let(:params) { default_params.merge({
      :dest_host     => 'ice.cream',
      :dest_host_key => 'pickle',
    })}

    it {
      should contain_sshkey('ice.cream').with_key('pickle')
    }

    it {
      # Leaky abstraction? We need to know that govuk::user creates the
      # parent directory for our file.
      should contain_file('/home/govuk-backup/.ssh').with_ensure('directory')
    }
  end
end
