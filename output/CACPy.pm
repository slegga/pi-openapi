# Python API Wrapper for cloudatcost.com


my $BASE_URL = "https://panel.cloudatcost.com/api/";
my $API_VERSION = "v1";

my $LIST_SERVERS_URL = "/listservers.php";
my $LIST_TEMPLATES_URL = "/listtemplates.php";
my $LIST_TASKS_URL = "/listtasks.php";
my $POWER_OPERATIONS_URL = "/powerop.php";
my $CONSOLE_URL = "/console.php";
my $RENAME_SERVER_URL = "/renameserver.php";
my $REVERSE_DNS_URL = "/rdns.php";
my $RUN_MODE_URL = "/runmode.php";

# CloudPRO functions:

my $SERVER_BUILD_URL = "/cloudpro/build.php";
my $SERVER_DELETE_URL = "/cloudpro/delete.php";
my $RESOURCE_URL = "/cloudpro/resources.php";


package CACPy;
use Mojo::Base -base, -signatures;
use Mojo::JSON 'decode_json';
use Mojo::UserAgent;
use Mojo::URL;
has ua => sub {Mojo::UserAgent->new};

=head2 Base class for making $self->ua to the cloud at cost API.
=cut

has 'self';
has 'email';
has 'api_key';


sub _make_request ($self, $endpoint, $options={}, $type="GET"){
        my $data = {
key => $self->api_key,login => $self->email};;

        # Add any passed in options to the data dictionary to be included
        # in the web request.
        for my $key(keys %$options) {
            $data->{$key} = $options->{$key};

        }
        my $url = $BASE_URL . $API_VERSION . $endpoint;
        my $ret = undef;
        if ($type eq "GET") {
            $ret = $self->ua->get(Mojo::URL->new($url)->query($data))->res->body;
        }
        elsif ($type eq "POST") {
            $ret = $self->ua->post(Mojo::URL->new($url)=>{Accept => '*/*'}=>form =>$data)->res->body;
        }
        else {
            die $type;

        }
        die $ret;
        return decode_json($ret)

    }
sub _commit_power_operation ($self, $server_id, $operation){
        my $options = {
sid => $server_id,action => $operation};;
        return $self->_make_request($POWER_OPERATIONS_URL, $options, "POST")

    }
sub get_server_info ($self){
=head2 Return an array of dictionaries containing server details.

        The dictionaries will contain keys consistent with the 'data'
        portion of the JSON as documented here:
        https://github.com/cloudatcost/api#list-servers
=cut
        return $self->_make_request($LIST_SERVERS_URL)

    }
sub get_template_info ($self){
=head2 Return an array of dictionaries containing template information.

        The dictionaries will contain keys consistent with the 'data'
        portion of the JSON as documented here:
        https://github.com/cloudatcost/api#list-templates
=cut
        return $self->_make_request($LIST_TEMPLATES_URL)

    }
sub get_task_info ($self){
=head2 Return an array of dictionaries containing task information.

        The dictionaries will contain keys consistent with the 'data'
        portion of the JSON as documented here:
        https://github.com/cloudatcost/api#list-tasks
=cut
        return $self->_make_request($LIST_TASKS_URL)

    }
sub power_on_server ($self, $server_id){
=head2 Request that the server specified be powered on.

        Required Arguments:
        server_id - The unique ID assaciated with the server to power on.
                    Specified by the 'sid' key returned by get_server_info()

        The return value will be a dictionary that will contain keys consistent
        with the JSON as documented here:
        https://github.com/cloudatcost/api#power-operations
=cut
        return $self->_commit_power_operation($server_id, 'poweron')

    }
sub power_off_server ($self, $server_id){
=head2 Request that the server specified be powered off.

        Required Arguments:
        server_id - The unique ID associated with the server to power off.
                    Specified by the 'sid' key returned by get_server_info()

        The return value will be a dictionary that will contain keys consistent
        with the JSON as documented here:
        https://github.com/cloudatcost/api#power-operations
=cut
        return $self->_commit_power_operation($server_id, 'poweroff')

    }
sub reset_server ($self, $server_id){
=head2 Request that the server specified be power cycled.

        Required Arguments:
        server_id - The unique ID associated with the server to power off.
                    Specified by the 'sid' key returned by get_server_info()

        The return value will be a dictionary that will contain keys consistent
        with the JSON as documented here:
        https://github.com/cloudatcost/api#power-operations
=cut
        return $self->_commit_power_operation($server_id, 'reset')

    }
sub rename_server ($self, $server_id, $new_name){
=head2 Modify the name label of the specified server.

        Required Arguments:
        server_id - The unique ID associated with the server to change the
                    label of. Specified by the 'sid' key returned by
                    get_server_info()
        new_name - String to set as the name label.

        The return value will be a dictionary that will contain keys consistent
        with the JSON as documented here:
        https://github.com/cloudatcost/api#rename-server
=cut
        my $options = {
sid => $server_id,name => $new_name};;
        return $self->_make_request($RENAME_SERVER_URL, $options, "POST")

    }
sub change_hostname ($self, $server_id, $new_hostname){
=head2 Modify the hostname of the specified server.

        Required Arguments:
        server_id - The unique ID associated with the server to change the
                    hostname of. Specified by the 'sid' key returned by
                    get_server_info()
        new_hostname - Fully qualified domain name to set for the host

        The return value will be a dictionary that will contain keys consistent
        with the JSON as documented here:
        https://github.com/cloudatcost/api#modify-reverse-dns
=cut
        my $options = {
sid => $server_id,hostname => $new_hostname};;
        return $self->_make_request($REVERSE_DNS_URL, $options, "POST")

    }
sub get_console_url ($self, $server_id){
=head2 Return the URL to the web console for the server specified.

        Required Arguments:
        server_id - The unique ID associated with the server you would
                    like the console URL for.
=cut
        my $options = {
sid => $server_id};;
        my $ret_data = $self->_make_request($CONSOLE_URL, $options, "POST");
        return ret_data{'console'};

    }
sub set_run_mode ($self, $server_id, $run_mode){
=head2 Set the run mode of the server.

        Required Arguments:
        server_id - The unique ID associated with the server to change the
                    hostname of. Specified by the 'sid' key returned by
                    get_server_info()
        run_mode -  Set the run mode of the server to either 'normal' or 'safe'.
                    Safe automatically turns off the server after 7 days of idle usage.
                    Normal keeps it on indefinitely.
=cut
        my $options = {
sid => $server_id,mode => $run_mode};;
        return $self->_make_request($RUN_MODE_URL, $options, "POST")

    }
sub server_build ($self, $cpu, $ram, $disk, $os){
=head2 Build a server from available cloudPRO resources.

        Required Arguments:
        cpu - The number of vCPUs to provision to the new server.
              Use an integer from 1 to 9.
        ram - The amount of memory to provision to the new server.
              Value in megabytes, must be a multiple of 4.
              Examples: 1024, 2048, 4096
        disk - The amount of disk space to provision to the server.
               Value in gigabytes in multiples of 10.
        os - The Operating System template to apply to the server.
             Specified by an id number returned by get_template_info()
=cut
        my $options = {
cpu => $cpu,ram => $ram,storage => $disk,os => $os};;
        return $self->_make_request($SERVER_BUILD_URL, $options, "POST")

    }
sub server_delete ($self, $server_id){
=head2 Delete a cloudPRO server and free associated resources.

        Required Arguments:
        server_id - The unique ID associated with the server to change the
                    hostname of. Specified by the 'sid' key returned by
                    get_server_info()
=cut
        my $options = {
sid => $server_id};;
        return $self->_make_request($SERVER_DELETE_URL, $options, "POST")

    }
sub get_resources ($self){
=head2 Returns information about CloudPRO resource usage.
=cut

        return $self->_make_request($RESOURCE_URL, "GET")
}
1
