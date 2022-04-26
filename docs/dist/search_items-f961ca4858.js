searchNodes=[{"doc":"Arnold main API functions, which can be used to communicate with other nodes or applications. The REST Api utilizes these functions mainly.","ref":"Arnold.html","title":"Arnold","type":"module"},{"doc":"Returns the correlation with each metric that was pushed for a node. If found positive or negative correlation for a threshold larger (or smaller) than 0.7 marks it as the metrics are correlating with each other. Example iex(1)&gt; Arnold . analyze ( &quot;node&quot; , &quot;sensor_id&quot; , :hourly , [ [ 1642433780 , 1642433840 , 1642433900 , 1642433960 , 1642434020 ] , [ 119027224.0 , 119214032.0 , 119363472.0 , 119483024.0 , 119578672.0 ] , [ 107124496.0 , 107292624.0 , 107427120.0 , 107534720.0 , 1.076208e8 ] [ 130929952.0 , 131135440.0 , 131299824.0 , 131431328.0 , 131536544.0 ] ] ) { :alarm , &quot;Current value is higher than the expected prediction range by X&quot; } iex(2)&gt;","ref":"Arnold.html#analyse/4","title":"Arnold.analyse/4","type":"function"},{"doc":"Feed data to the sensors. It is going to be marked for train if the threshold is reached for the current input category. Example iex(1)&gt; Arnold . feed ( &quot;node&quot; , &quot;sensor_id&quot; , 1642433780 , 5 ) :ok iex(2)&gt;","ref":"Arnold.html#feed/4","title":"Arnold.feed/4","type":"function"},{"doc":"Predicts a value for a given id and tag . Check out the :windows to see the available tag values. There are two types of predictions: simple and complex . Complex uses the trained neural network, while the simple is only used when there aren't any networks for the current id. It uses SES algorithm for predictions. Example iex(1)&gt; Arnold . predict ( &quot;node_sensor_uuid&quot; , :hourly , 5 ) { ok , [ [ 1642433780 , 1642433840 , 1642433900 , 1642433960 , 1642434020 ] , [ 119027224.0 , 119214032.0 , 119363472.0 , 119483024.0 , 119578672.0 ] , [ 107124496.0 , 107292624.0 , 107427120.0 , 107534720.0 , 1.076208e8 ] [ 130929952.0 , 131135440.0 , 131299824.0 , 131431328.0 , 131536544.0 ] ] } iex(2)&gt;","ref":"Arnold.html#predict/3","title":"Arnold.predict/3","type":"function"},{"doc":"Predicts a value for a given node , sensor_id and tag . Check out the :windows to see the available tag values. Calls for predict/2 . Example iex(1)&gt; Arnold . predict ( &quot;node&quot; , &quot;sensor_id&quot; , :hourly , 5 ) { ok , [ [ 1642433780 , 1642433840 , 1642433900 , 1642433960 , 1642434020 ] , [ 119027224.0 , 119214032.0 , 119363472.0 , 119483024.0 , 119578672.0 ] , [ 107124496.0 , 107292624.0 , 107427120.0 , 107534720.0 , 1.076208e8 ] [ 130929952.0 , 131135440.0 , 131299824.0 , 131431328.0 , 131536544.0 ] ] } iex(2)&gt;","ref":"Arnold.html#predict/4","title":"Arnold.predict/4","type":"function"},{"doc":"Configuration handler module for Arnold.","ref":"Arnold.Config.html","title":"Arnold.Config","type":"module"},{"doc":"Fetches a config value with a given key. The following default configs are configured for Arnold: Example iex(1)&gt; Arnold.Config . get ( :port ) { :ok , 8081 } iex(2)&gt; The windows and ports are hard coded with the following default values: :hourly = 60 :daily = 96 :weekly = 168 :port = 8081 Port can be configured via a config file or setting the ARNOLD_PORT environment variable. Example iex(1)&gt; Arnold.Config . get ( :window , :hourly ) { :ok , 60 , 3600 } iex(2)&gt;","ref":"Arnold.Config.html#get/1","title":"Arnold.Config.get/1","type":"function"},{"doc":"Returns a value for a given window_type . The following types are accepted: :hourly :daily :weekly Example iex(1)&gt; Arnold.Config . get ( :window , :hourly ) { :ok , 60 , 3600 } iex(2)&gt;","ref":"Arnold.Config.html#get/2","title":"Arnold.Config.get/2","type":"function"},{"doc":"API wrapper for Memento to store or fetch data from the database.","ref":"Arnold.Database.html","title":"Arnold.Database","type":"module"},{"doc":"Fetches data from database. Needs a table schema and an uuid which is made from the combination of node_name and sensor_id with Arnold.Utilities.id/2 . Example iex(1)&gt; Arnold.Database ( Arnold.Database.Table.Sensor , &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; ) { :ok , % Arnold.Database.Table.Sensor { id : &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; , hourly : [ { 1610986020 , 5 } ] , daily : [ ] , weekly : [ ] , predictions : %{ hourly : [ [ ] , [ ] , [ ] , [ ] ] , daily : [ [ ] , [ ] , [ ] , [ ] ] , weekly : [ [ ] , [ ] , [ ] , [ ] ] } } } iex(2)&gt;","ref":"Arnold.Database.html#get/2","title":"Arnold.Database.get/2","type":"function"},{"doc":"Tries to fetch a specific node_id and sensor_id from a table. If not found returns all the currently saved data from the backend","ref":"Arnold.Database.html#get/3","title":"Arnold.Database.get/3","type":"function"},{"doc":"Inserts the data to the specific table of the Postgres database. If it's there updates the value","ref":"Arnold.Database.html#insert/1","title":"Arnold.Database.insert/1","type":"function"},{"doc":"Memento table for saving the manager state. Structure % Arnold.Database.Table.Manager { id : &quot;arnold_manager&quot; , finished : MapSet &lt; [ ] &gt; , hash_table : %{ } , sensor_agents : 40 } Attributes id : table id, hard coded for &quot;arnold_manager&quot; finished : MapSet of all the finished sensor ids and tags {sensor_id, tag} hash_table : Map of key-values for the Load Balancer. sensor_agents : Number of sensor agents that should be active","ref":"Arnold.Database.Table.Manager.html","title":"Arnold.Database.Table.Manager","type":"module"},{"doc":"","ref":"Arnold.Database.Table.Manager.html#t:t/0","title":"Arnold.Database.Table.Manager.t/0","type":"type"},{"doc":"Memento table for neural network weights. Structure % Arnold.Database.Table.NetworkModel { id : &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; , dataset : %{ } , model : %{ } , model_state : %{ } , } Attributes id : table id, equal to sensor id dataset : dataset model : table id, equal to sensor id model_state : table id, equal to sensor id","ref":"Arnold.Database.Table.NetworkModel.html","title":"Arnold.Database.Table.NetworkModel","type":"module"},{"doc":"","ref":"Arnold.Database.Table.NetworkModel.html#t:t/0","title":"Arnold.Database.Table.NetworkModel.t/0","type":"type"},{"doc":"Memento table for sensors. Structure % Arnold.Database.Table.Sensor { id : &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; , hourly : [ ] , daily : [ ] , weekly : [ ] , predictions : %{ hourly : [ [ ] , [ ] , [ ] , [ ] ] , daily : [ [ ] , [ ] , [ ] , [ ] ] , weekly : [ [ ] , [ ] , [ ] , [ ] ] } } Attributes id : table id, equal to sensor id hourly : Hourly list of inputs, with timestamps (received every minute) daily : Daily list of inputs, with timestamps (received every 5 minute) weekly : Weekly list of inputs, with timestamps (received every 15 minute) predictions : Map of predictions per tag.","ref":"Arnold.Database.Table.Sensor.html","title":"Arnold.Database.Table.Sensor","type":"module"},{"doc":"","ref":"Arnold.Database.Table.Sensor.html#t:t/0","title":"Arnold.Database.Table.Sensor.t/0","type":"type"},{"doc":"The manager responsible for saving sensors state, finished sensor tags and the number of sensor agents. If an agent terminates it the duty of the module to start a new one.","ref":"Arnold.Manager.html","title":"Arnold.Manager","type":"module"},{"doc":"Returns a specification to start this module under a supervisor. See Supervisor .","ref":"Arnold.Manager.html#child_spec/1","title":"Arnold.Manager.child_spec/1","type":"function"},{"doc":"Returns all metrics for a given node. Used for getting all the metrics for a given node to check the correlations. Returns an empty MapSet if node not found. Example iex(1)&gt; Arnold.Manager . get ( &quot;node&quot; ) # MapSet &lt; [ &quot;sensor_id&quot; ] &gt; iex(2)&gt;","ref":"Arnold.Manager.html#get_metrics/1","title":"Arnold.Manager.get_metrics/1","type":"function"},{"doc":"Returns the state of the manager server. Example iex(1)&gt; Arnold.Manager . get_state %{ :timers =&gt; %{ sensor : { :interval , # Reference &lt; 0.3386470258 . 2604662794.215684 &gt; } , marks : { :interval , # Reference &lt; 0.3386470258 . 2604662794.315674 &gt; } } , :marks =&gt; # MapSet &lt; [ ] &gt; , :finished =&gt; # MapSet &lt; [ ] &gt; , :metriccs =&gt; Map } iex(2)&gt;","ref":"Arnold.Manager.html#get_state/0","title":"Arnold.Manager.get_state/0","type":"function"},{"doc":"Checks if the id with the given tag has already finished training. Example iex(1)&gt; Arnold.Manager . is_finished? ( &quot;node_sensor_id&quot; , :hourly ) true iex(2)&gt;","ref":"Arnold.Manager.html#is_finished?/2","title":"Arnold.Manager.is_finished?/2","type":"function"},{"doc":"Marks an id with a given tag for training. Example iex(1)&gt; Arnold.Manager . mark ( &quot;node_sensor_id&quot; , :hourly ) :ok iex(2)&gt;","ref":"Arnold.Manager.html#mark/2","title":"Arnold.Manager.mark/2","type":"function"},{"doc":"Registers a metric to the state of the manager. Later is used for getting all the metrics for a given node to check the correlations. Example iex(1)&gt; Arnold.Manager . register ( &quot;node&quot; , &quot;sensor_id&quot; ) :ok iex(2)&gt;","ref":"Arnold.Manager.html#register_metric/2","title":"Arnold.Manager.register_metric/2","type":"function"},{"doc":"Starts a GenServer process linked to the current process. Check GenServer.start_link/3 for more.","ref":"Arnold.Manager.html#start_link/2","title":"Arnold.Manager.start_link/2","type":"function"},{"doc":"The neural network API that contains function for training and prediction.","ref":"Arnold.NeuralNetwork.html","title":"Arnold.NeuralNetwork","type":"module"},{"doc":"Predict a value or a list of values or a single value based on the method which can be :complex or :simple . Simple type utilizes the Single Exponential Smoothing algorithm from Arnold.Analyser.ExponentialSmoothing.simple/1 , which is only good for predicting one value ahead. Complex uses neural network while also affects the results by trend and seasonality. If the sensor is nil it returns nil . Example iex(1)&gt; Arnold.NeuralNetwork . predict ( % Arnold.Database.Table.Sensor { ...(1)&gt; id : &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; , ...(1)&gt; hourly : [ { 1642594108 , 4 } ] , daily : [ ] , weekly : [ ] } , :hourly , 1 , :simple ) { :ok , [ [ 1642594108 ] , [ 4 ] , [ 4.8 ] , [ 3.2 ] ] } iex(2)&gt;","ref":"Arnold.NeuralNetwork.html#predict/4","title":"Arnold.NeuralNetwork.predict/4","type":"function"},{"doc":"Saves the given result from the Arnold.NeuralNetwork.train/1 function.","ref":"Arnold.NeuralNetwork.html#save/1","title":"Arnold.NeuralNetwork.save/1","type":"function"},{"doc":"Trains the neural network with the given sensor and tag , until a configure eps value is not reached. If it fails to reach the given epsilon value, the training stops when exceeding the :max_iterates config value. Example iex(1)&gt; Arnold.NeuralNetwork . train ( % Arnold.Database.Table.Sensor { ...(1)&gt; id : &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; , ...(1)&gt; hourly : [ { 1642593268 , 5 } , { 1642593208 , 6 } , { 1642593148 , 4 } , { 1642593088 , 8 } , { 1642593028 , 0 } ... ] , ...(1)&gt; daily : [ { 1642594108 , 4 } , { 1642593808 , 7 } , { 1642593508 , 2 } , { 1642593208 , 5 } ] , weekly : [ ] } , :hourly ) % Arnold.Database.Table.NetworkModel { } iex(2)&gt;","ref":"Arnold.NeuralNetwork.html#train/1","title":"Arnold.NeuralNetwork.train/1","type":"function"},{"doc":"Prediction result. A 4 element list of list of integers. List of timestamps List of predictions List of upper range predictions List of lower range predictions [ [ ] , [ ] , [ ] , [ ] , [ ] ]","ref":"Arnold.NeuralNetwork.html#t:prediction/0","title":"Arnold.NeuralNetwork.prediction/0","type":"type"},{"doc":"Prediction method type that can be set as the third argument of Arnold.NeuralNetwork.predict/4","ref":"Arnold.NeuralNetwork.html#t:prediction_method/0","title":"Arnold.NeuralNetwork.prediction_method/0","type":"type"},{"doc":"Router for the REST API. There are 2 main routes, get and post paths. The body must be a json in all cases. GET paths: /api/tendency (not used) /api/seasonality (not used) /api/prediction All of them needs 3 common parameters: node metric tag Prediction route needs a 4th one: horizon As a result a sample url path should look like this (port can be customized): http://localhost:8081/api/tendency?node=node_id&amp;metric=metric_id&amp;tag=hourly POST path: /api/write Parameters: node metric Body: type value timestamp Currently only gauge, counter, meter, spiral, histogram and durations are accepted via the router. A sample url: http://localhost:8081/api/write?node=node_id&amp;metric=metric_id with body as json { &quot;type&quot;: &quot;gauge&quot;, &quot;timestamp&quot;: 1642433780, &quot;value&quot;: 75 } Both GET and POST methods has built-in request verification. Arnold.Plug.InvalidGetParams or Arnold.Plug.InvalidPostParams errors are raised if the sent request are not valid.","ref":"Arnold.Plug.Router.html","title":"Arnold.Plug.Router","type":"module"},{"doc":"Callback implementation for Plug.call/2 .","ref":"Arnold.Plug.Router.html#call/2","title":"Arnold.Plug.Router.call/2","type":"function"},{"doc":"Callback implementation for Plug.init/1 .","ref":"Arnold.Plug.Router.html#init/1","title":"Arnold.Plug.Router.init/1","type":"function"},{"doc":"Contains the API functions for the sensors","ref":"Arnold.Sensor.html","title":"Arnold.Sensor","type":"module"},{"doc":"Returns all sensors from every sensor agent. Example iex(1)&gt; Arnold.Sensor . all [ % Arnold.Database.Table.Sensor { id : &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; , hourly : [ { 1610986020 , 5 } ] , daily : [ ] , weekly : [ ] , predictions : %{ hourly : [ [ ] , [ ] , [ ] , [ ] ] , daily : [ [ ] , [ ] , [ ] , [ ] ] , weekly : [ [ ] , [ ] , [ ] , [ ] ] } } , % Arnold.Database.Table.Sensor { id : &quot;adff7462-a100-55be-8ee1-8f8c34d3a9e3&quot; , hourly : [ { 1610986020 , 6 } ] , daily : [ ] , weekly : [ ] , predictions : %{ hourly : [ [ ] , [ ] , [ ] , [ ] ] , daily : [ [ ] , [ ] , [ ] , [ ] ] , weekly : [ [ ] , [ ] , [ ] , [ ] ] } } ] iex(2)&gt;","ref":"Arnold.Sensor.html#all/0","title":"Arnold.Sensor.all/0","type":"function"},{"doc":"Deletes a sensor from a given uuid . UUID is the combination of node_id and sensor_id made with Arnold.Utilities.id/2 . Example iex(1)&gt; Arnold.Sensor . delete ( &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; ) :ok iex(2)&gt;","ref":"Arnold.Sensor.html#delete/1","title":"Arnold.Sensor.delete/1","type":"function"},{"doc":"Returns a sensor from with the given uuid . Only returns the sensor if it is in the state of the agent. UUID is the combination of node_id and sensor_id made with Arnold.Utilities.id/2 . Example iex(1)&gt; Arnold.Sensor . get ( &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; ) % Arnold.Database.Table.Sensor { id : &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; , hourly : [ { 1610986020 , 5 } ] , daily : [ ] , weekly : [ ] , predictions : %{ hourly : [ [ ] , [ ] , [ ] , [ ] ] , daily : [ [ ] , [ ] , [ ] , [ ] ] , weekly : [ [ ] , [ ] , [ ] , [ ] ] } } iex(2)&gt;","ref":"Arnold.Sensor.html#get/1","title":"Arnold.Sensor.get/1","type":"function"},{"doc":"","ref":"Arnold.Sensor.html#merge/3","title":"Arnold.Sensor.merge/3","type":"function"},{"doc":"Creates a new Sensor with the given uuid and input value. UUID is the combination of node_id and sensor_id made with Arnold.Utilities.id/2 . Example iex(1)&gt; Arnold.Sensor . new ( &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; , 1610986020 , 5 ) % Arnold.Database.Table.Sensor { id : &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; , hourly : [ { 1610986020 , 5 } ] , daily : [ ] , weekly : [ ] , predictions : %{ hourly : [ [ ] , [ ] , [ ] , [ ] ] , daily : [ [ ] , [ ] , [ ] , [ ] ] , weekly : [ [ ] , [ ] , [ ] , [ ] ] } } iex(2)&gt;","ref":"Arnold.Sensor.html#new/3","title":"Arnold.Sensor.new/3","type":"function"},{"doc":"Puts a given sensor with a value into one of the agent's state. The function creates a new sensor if the agent failed to find it in its state or in the database, or if found one updates it. The agent calls the Arnold.Sensor.new/3 and Arnold.Sensor.update/3 functions. Example iex(1)&gt; Arnold.Sensor . put ( &quot;node&quot; , &quot;sensor&quot; , 5 ) % Arnold.Database.Table.Sensor { id : &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; , hourly : [ { 1610986020 , 5 } ] , daily : [ ] , weekly : [ ] , predictions : %{ hourly : [ [ ] , [ ] , [ ] , [ ] ] , daily : [ [ ] , [ ] , [ ] , [ ] ] , weekly : [ [ ] , [ ] , [ ] , [ ] ] } } iex(2)&gt;","ref":"Arnold.Sensor.html#put/4","title":"Arnold.Sensor.put/4","type":"function"},{"doc":"Resets a sensor with a given uuid and tag . It means that truncates the input values for the given tag . UUID is the combination of node_id and sensor_id made with Arnold.Utilities.id/2 . Example iex(1)&gt; Arnold.Sensor . reset ( &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; , :hourly ) :ok iex(2)&gt;","ref":"Arnold.Sensor.html#reset/2","title":"Arnold.Sensor.reset/2","type":"function"},{"doc":"Updates a given sensor with a value Example iex(1)&gt; Arnold.Sensor . update ( % Arnold.Database.Table.Sensor { ...(1)&gt; id : &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; , ...(1)&gt; hourly : [ { 1610986020 , 5 } ] , ...(1)&gt; daily : [ ] , ...(1)&gt; weekly : [ ] , ...(1)&gt; predictions : %{ hourly : [ [ ] , [ ] , [ ] , [ ] ] , daily : [ [ ] , [ ] , [ ] , [ ] ] , weekly : [ [ ] , [ ] , [ ] , [ ] ] } } , 1642593088 , 7 ) % Arnold.Database.Table.Sensor { id : &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; , hourly : [ { 1642593088 , 7 } , { 1610986020 , 5 } ] , daily : [ ] , weekly : [ ] , predictions : %{ hourly : [ [ ] , [ ] , [ ] , [ ] ] , daily : [ [ ] , [ ] , [ ] , [ ] ] , weekly : [ [ ] , [ ] , [ ] , [ ] ] } } iex(2)&gt;","ref":"Arnold.Sensor.html#update/3","title":"Arnold.Sensor.update/3","type":"function"},{"doc":"Gets the values from the input proplist. Example iex(1)&gt; Arnold.Sensor . values ( [ { 1610986020 , 46386 } , { 1610989620 , 3456 } ] ) [ 46386 , 3456 ] iex(2)&gt;","ref":"Arnold.Sensor.html#values/1","title":"Arnold.Sensor.values/1","type":"function"},{"doc":"Time tag for sensor","ref":"Arnold.Sensor.html#t:tag/0","title":"Arnold.Sensor.tag/0","type":"type"},{"doc":"Dynamic supervisor which can start Sensor Agents when needed.","ref":"Arnold.Sensor.Supervisor.html","title":"Arnold.Sensor.Supervisor","type":"module"},{"doc":"Returns the number of active children for the supervisor. May differ from the number of children Example iex(1)&gt; Arnold.Supervisor . active_children 1 iex(2)&gt;","ref":"Arnold.Sensor.Supervisor.html#active_children/0","title":"Arnold.Sensor.Supervisor.active_children/0","type":"function"},{"doc":"Returns a specification to start this module under a supervisor. See Supervisor .","ref":"Arnold.Sensor.Supervisor.html#child_spec/1","title":"Arnold.Sensor.Supervisor.child_spec/1","type":"function"},{"doc":"Returns the number of workers for the supervisor. Example iex(1)&gt; Arnold.Supervisor . children 2 iex(2)&gt;","ref":"Arnold.Sensor.Supervisor.html#children/0","title":"Arnold.Sensor.Supervisor.children/0","type":"function"},{"doc":"Restarts a child with the given id . Example iex(1)&gt; Arnold.Supervisor . restart_child ( :sensor1 ) { :ok , # PID &lt; 0 . 345 . 0 &gt; } iex(2)&gt;","ref":"Arnold.Sensor.Supervisor.html#restart_child/1","title":"Arnold.Sensor.Supervisor.restart_child/1","type":"function"},{"doc":"Starts a child with the given id . Example iex(1)&gt; Arnold.Supervisor . start_child ( :sensor1 ) { :ok , # PID &lt; 0 . 345 . 0 &gt; } iex(2)&gt;","ref":"Arnold.Sensor.Supervisor.html#start_child/1","title":"Arnold.Sensor.Supervisor.start_child/1","type":"function"},{"doc":"Starts a supervisor with the given children. Example iex(1)&gt; Arnold.Supervisor . start_link ( ) { :ok , # PID &lt; 0 . 3834 . 0 &gt; } iex(2)&gt;","ref":"Arnold.Sensor.Supervisor.html#start_link/1","title":"Arnold.Sensor.Supervisor.start_link/1","type":"function"},{"doc":"Decompose the input values into trend and seasonality.","ref":"Arnold.Statistics.Decomposition.html","title":"Arnold.Statistics.Decomposition","type":"module"},{"doc":"Decompose uses a multiplicative decomposition method. InputData = Trend * Seasonality * Noise The function returns a 3-element tuple, which contains where the the first element is the trend, followed by seasonality, then noise for the last place. For more information checkout this page: https://otexts.com/fpp2/components.html","ref":"Arnold.Statistics.Decomposition.html#execute/1","title":"Arnold.Statistics.Decomposition.execute/1","type":"function"},{"doc":"","ref":"Arnold.Statistics.Decomposition.html#trend/1","title":"Arnold.Statistics.Decomposition.trend/1","type":"function"},{"doc":"Collection of exponential smoothing algorithms. simple (SES, or Single Exponential Smoothing) double (DWA, Holts Double Exponential Smoothing, Holt’s linear trend method)","ref":"Arnold.Statistics.ExponentialSmoothing.html","title":"Arnold.Statistics.ExponentialSmoothing","type":"module"},{"doc":"Double Exponential Smoothing algorithm. Double Exponential Smoothing(DWA) is also called as Holts Double Exponential Smoothing. Double Exponential Smoothing is extended form of Simple Exponential Smoothing. Double Exponential Smoothing technique is used for forecasting with trending data.It has level and trend but it does not have seasonality. Unlike SES, it can optionally extended with a horizon parameter which tells the algorithm how far should it look ahaed for forecasting. For more information checkout this page: https://otexts.com/fpp2/holt.html https://medium.com/@shrikantpandeymnnit2015/time-series-analysis-and-its-different-approach-in-python-part-1-714dee28041f Example iex(1)&gt; Nx . tensor ( [ 10 , 11 , 12 , 13 ] ) |&gt; Arnold.Analyser.ExponentialSmoothing . double # Nx.Tensor &lt; f32 [ 1 ] [ 9.0 ] &gt; iex(2)&gt;","ref":"Arnold.Statistics.ExponentialSmoothing.html#double/2","title":"Arnold.Statistics.ExponentialSmoothing.double/2","type":"function"},{"doc":"Simple Exponential Smoothing algorithm. SES is a time series forecasting method for univariate data without a trend or seasonality. It requires a single parameter, which is hard coded, called alpha, also called the smoothing factor or smoothing coefficient. For more information checkout this page: https://otexts.com/fpp2/ses.html Example iex(1)&gt; Nx . tensor ( [ 1 , 2 , 3 , 4 , 5 , 6 ] ) |&gt; Arnold.Analyser.ExponentialSmoothing . simple # Nx.Tensor &lt; f32 2.1164159774780273 &gt; iex(2)&gt;","ref":"Arnold.Statistics.ExponentialSmoothing.html#simple/2","title":"Arnold.Statistics.ExponentialSmoothing.simple/2","type":"function"},{"doc":"Triple Exponential Smoothing algorithm. Triple Exponential Smoothing is also known as “Halt-Winters Method”. When we have the level ,trend and seasonality in data set then we use Triple Exponential Smoothing or Halts’ Winter Method. It is similar to Double Exponential Smoothing , we add one extra parameter gamma(seasonality) for Halts’ Winter Method. In Halts’ Winter Method there is three smoothing parameters alpha(α),beta(β),gamma(γ). For more information checkout this page: https://medium.com/@shrikantpandeymnnit2015/time-series-analysis-and-its-different-approach-in-python-part-1-714dee28041f https://otexts.com/fpp2/holt-winters.html Example iex(1)&gt; Nx . tensor ( [ 10 , 11 , 12 , 13 , 12 , 11 , 10 , 11 , 12 , 14 , 13 , 11 , 10 ] ) |&gt; Arnold.Analyser.ExponentialSmoothing . triple ( 2 , 7 ) [ # Nx.Tensor &lt; f32 13.446951866149902 &gt; , # Nx.Tensor &lt; f32 14.956113815307617 &gt; ] iex(2)&gt;","ref":"Arnold.Statistics.ExponentialSmoothing.html#triple/3","title":"Arnold.Statistics.ExponentialSmoothing.triple/3","type":"function"},{"doc":"Collection of commonly used mathematical/statistic functions.","ref":"Arnold.Statistics.Math.html","title":"Arnold.Statistics.Math","type":"module"},{"doc":"Calculates the sum of the squared deviations from the mean, without dividing by N or by N-1. Example iex(1)&gt; Nx . tensor ( [ 1 , 2 , 3 , 4 , 5 , 6 ] ) |&gt; Arnold.Analyser.Math . devsq # Nx.Tensor &lt; f32 17.5 &gt; iex(2)&gt;","ref":"Arnold.Statistics.Math.html#devsq/1","title":"Arnold.Statistics.Math.devsq/1","type":"function"},{"doc":"","ref":"Arnold.Statistics.Math.html#differencing/3","title":"Arnold.Statistics.Math.differencing/3","type":"function"},{"doc":"Calculates the percentage between 0 and 1 of x and y . Always the smaller number is divided by the larger. Example iex(1)&gt; Arnold.Analyser.Math . percentage ( 5 , 4 ) 0.8 iex(2)&gt; Arnold.Analyser.Math . percentage ( 4 , 5 ) 0.8 iex(3)&gt;","ref":"Arnold.Statistics.Math.html#percentage/2","title":"Arnold.Statistics.Math.percentage/2","type":"function"},{"doc":"Simple Moving Average algorithm Calculation that is used to analyze data points by creating a series of averages of different subsets of the full data set. Example iex(1)&gt; Nx . tensor ( [ 1 , 2 , 3 , 4 , 5 , 6 ] ) |&gt; Arnold.Analyser.Math . sma ( 2 ) # Nx.Tensor &lt; f32 [ 5 ] [ 1.5 , 2.5 , 3.5 , 4.5 , 5.5 ] &gt; iex(2)&gt;","ref":"Arnold.Statistics.Math.html#sma/2","title":"Arnold.Statistics.Math.sma/2","type":"function"},{"doc":"Function for calculating the standard deviation of the given set of numbers. Example iex(1)&gt; Arnold.Analyser.Math . std ( Nx . tensor ( [ 4 , 7 , 2 , 1 , 6 , 3 ] ) ) # Nx.Tensor &lt; f32 2.114763021469116 &gt; iex(2)&gt;","ref":"Arnold.Statistics.Math.html#std/2","title":"Arnold.Statistics.Math.std/2","type":"function"},{"doc":"Estimates the variance of a sample of data. The variance function is a measure of heteroscedasticity and plays a large role in many settings of statistical modelling Example iex(1)&gt; Nx . tensor ( [ 1 , 2 , 3 , 4 , 5 , 6 ] ) |&gt; Arnold.Analyser.Math . variance # Nx.Tensor &lt; f32 3.5 &gt; iex(2)&gt;","ref":"Arnold.Statistics.Math.html#variance/1","title":"Arnold.Statistics.Math.variance/1","type":"function"},{"doc":"Top-level supervisor of the Arnold application.","ref":"Arnold.Supervisor.html","title":"Arnold.Supervisor","type":"module"},{"doc":"Returns a specification to start this module under a supervisor. See Supervisor .","ref":"Arnold.Supervisor.html#child_spec/1","title":"Arnold.Supervisor.child_spec/1","type":"function"},{"doc":"Starts a Supervisor process linked to the current process. Check Supervisor.start_link/3 for more.","ref":"Arnold.Supervisor.html#start_link/1","title":"Arnold.Supervisor.start_link/1","type":"function"},{"doc":"Collection of utility functions including id generation, truncate and normalization functions.","ref":"Arnold.Utilities.html","title":"Arnold.Utilities","type":"module"},{"doc":"Denormalizes a value with the given min and max value. Example: iex(1)&gt; Arnold.Utilities.denormalize(0.75,1,5) 4.0 iex(2)&gt;","ref":"Arnold.Utilities.html#denormalize/3","title":"Arnold.Utilities.denormalize/3","type":"function"},{"doc":"Return a generated UUID v5 based on the given ids. Example iex(1)&gt; Arnold.Utilities . id ( &quot;node&quot; , &quot;sensor&quot; ) &quot;85a68cb6-04c7-5a78-8f4c-bcc184186b6b&quot; iex(2)&gt;","ref":"Arnold.Utilities.html#id/2","title":"Arnold.Utilities.id/2","type":"function"},{"doc":"","ref":"Arnold.Utilities.html#integer_to_boolean/1","title":"Arnold.Utilities.integer_to_boolean/1","type":"function"},{"doc":"Checks if the given list is only has constant values. Example iex(1)&gt; Arnold.Utilities . is_constant? ( [ 1 , 2 , 3 , 4 , 5 , 6 ] ) false iex(2)&gt;","ref":"Arnold.Utilities.html#is_constant?/1","title":"Arnold.Utilities.is_constant?/1","type":"function"},{"doc":"Returns the result of the normalize function return value. Mainly used in pipe operations Example iex(1)&gt; Arnold.Utilities . normalize ( 4 , 1 , 5 ) ...(1)&gt; |&gt; Arnold.Utilities . normal_result 0.75 iex(2)&gt;","ref":"Arnold.Utilities.html#normal_result/1","title":"Arnold.Utilities.normal_result/1","type":"function"},{"doc":"Normalizes a list of floats or integers with min-max normalization. Automatically gets the minimum and maximum values from the given list. Calls to Arnold.Utilities.normalize/3 Example iex(1)&gt; Arnold.Utilities . normalize ( [ 1 , 2 , 3 , 4 , 5 ] ) { [ 0.0 , 0.25 , 0.5 , 0.75 , 1.0 ] , 1 , 5 } iex(2)&gt;","ref":"Arnold.Utilities.html#normalize/1","title":"Arnold.Utilities.normalize/1","type":"function"},{"doc":"Normalizes a list of floats or integers, or single values with min-max normalization. For every element Arnold.Utilities.normalize/3 is called. Example iex(1)&gt; Arnold.Utilities . normalize ( 4 , 1 , 5 ) { 0.75 , 1 , 5 } iex(2)&gt;","ref":"Arnold.Utilities.html#normalize/3","title":"Arnold.Utilities.normalize/3","type":"function"},{"doc":"Truncates a given list to the given length Example iex(1)&gt; Arnold.Utilities . truncate ( [ 1 , 2 , 3 , 4 , 5 ] , 4 ) [ 1 , 2 , 3 , 4 ] iex(2)&gt;","ref":"Arnold.Utilities.html#truncate/2","title":"Arnold.Utilities.truncate/2","type":"function"},{"doc":"Collection of benchmark functions","ref":"Arnold.Utilities.Benchmark.html","title":"Arnold.Utilities.Benchmark","type":"module"},{"doc":"Measure the execution time of a given function in seconds. Example iex(1)&gt; Arnold.Utilities.Benchmark . measure ( fn -&gt; 2 + 5 end ) 5.0e-6 iex(2)&gt;","ref":"Arnold.Utilities.Benchmark.html#measure/1","title":"Arnold.Utilities.Benchmark.measure/1","type":"function"},{"doc":"Error raised when a required field is missing. Error message: &quot;Invalid params found, use these: [node, metric, tag] with tag: [hourly, daily, weekly]&quot;","ref":"Arnold.Plug.InvalidGetParams.html","title":"Arnold.Plug.InvalidGetParams","type":"exception"},{"doc":"Error raised when a required field is missing. Error message: &quot;Invalid params found, use these: [node, metric]&quot;","ref":"Arnold.Plug.InvalidPostParams.html","title":"Arnold.Plug.InvalidPostParams","type":"exception"},{"doc":"Neural Network for time series data forecasting using Axon library","ref":"readme.html","title":"README","type":"extras"},{"doc":"Lightweight REST API Automatic training after reaching certain threshold Load Balancing Analyser tools Simple &amp; Complex predictions Arnold is a neural network built as an analysing and forecasting tool for time series data. Used by WombatOAM . The goal was to integrate a tool that can analyse the incoming metrics and forecast upcoming values, alert users when a monitored metric reaches a certain threshold, dynamic alerts, and much more. Arnold is capable of returning the trend and seasonality components, which are calculated with a decomposition method, then added back to the final prediction result. Documentation is available here Installation &amp; Usage","ref":"readme.html#features","title":"README - Features","type":"extras"},{"doc":"Arnold has package releases for both osx and linux. Download the favored version from github packages page. Uncompress it with tar like the following way: foo@bar:~$ tar -xf arnold-{VERSION}-{OS}.tar.gz Then can be started like foo@bar:~$ arnold-{VERSION}-{OS}/bin/arnold start","ref":"readme.html#packages","title":"README - Packages","type":"extras"},{"doc":"Prerequisites Arnold requires Elixir 1.13 or later version and Erlang/OTP 24.0 or later version. Build Clone the repository to your custom destination. foo@bar:~$ git clone https://github.com/esl/arnold.git Run the following command to get a dependencies and build Arnold foo@bar:~$ make build Recommened way of start a Arnold node is the interactive mode with the shell using foo@bar:~$ make console If you would like to create a release version of Arnold TARGET varibale should be set before running distillery . foo@bar:~$ make release TARGET=osx If not set it is going to use the default dev environment. All configurations can be checked in the rel/config.exs","ref":"readme.html#build-from-source","title":"README - Build from source","type":"extras"},{"doc":"For most cases there are two possible optios to use RestAPI Arnold module Feeding data RestAPI url / api / write? node = NodeID &amp; metric = MetricName It has two query parameters NodeID: Node name MetricName: Name of the metric which is going to appear in Arnold as SensorID Body is sent as a json object. { &quot;type&quot;: &quot;gauge&quot;, &quot;value&quot;: 5, &quot;timestamp&quot;: 1642433780 } Type: Metric type like gauge, counter etc. Arnold has its own way of dealing with metrics. It can be extended with multiple types as well. Value: Single numeric value (could be a float) Timestamp: time when the metric value was created Arnold module iex(1)&gt; Arnold . feed ( &quot;node&quot; , &quot;sensor_id&quot; , 1642433780 , 5 ) :ok iex(2)&gt; Retriving predictions RestAPI url / api / prediction? node = NodeID &amp; metric = MetricName &amp; tag = Tag &amp; horizon = Horizon It has two query parameters NodeID: Node name MetricName: Name of the metric which is going to appear in Arnold as SensorID Tag: Time period tag (hourly, daily, weekly) Horizon: Forecast horizon, quantity of metrics to be forecasted after of the latest timestamp. Body is empty. Arnold module iex(1)&gt; Arnold . predict ( &quot;node&quot; , &quot;sensor_id&quot; , :hourly , 5 ) { ok , [ [ 1642433780 , 1642433840 , 1642433900 , 1642433960 , 1642434020 ] , [ 119027224.0 , 119214032.0 , 119363472.0 , 119483024.0 , 119578672.0 ] , [ 107124496.0 , 107292624.0 , 107427120.0 , 107534720.0 , 1.076208e8 ] [ 130929952.0 , 131135440.0 , 131299824.0 , 131431328.0 , 131536544.0 ] ] } iex(2)&gt; Returning data is Highcharts friendly for easier use.","ref":"readme.html#basic-usage","title":"README - Basic Usage","type":"extras"},{"doc":"compile : Compiles Arnold deps : Gets the deps build : Previos two commands together. Needs a clean repo. release : Creates a release. If TARGET is defined it uses the given values as a mix environment. console : Starts a dev console docs : Makes the docs using ExDoc dialyzer : Runs dialyzer clean : Cleans the folder like it was just cloned Useage foo@bar:~$ make COMMAND","ref":"readme.html#makefile-commands","title":"README - Makefile commands","type":"extras"},{"doc":"By default the port 8081 is used for the RestAPI but can be configure for a custom port number. config :arnold , port : 8081","ref":"readme.html#config","title":"README - Config","type":"extras"},{"doc":"Axon : Neural Network Nx : Tensor Memento : Mnesia storage backend API Plug_cowboy : RestAPI Logger_file_backend : Logging to file Uuid : ID generation Distillery : Release and package creation Dialyxir : dev only, dialyzer ExDocs : dev only, Documentation of the project","ref":"readme.html#dependencies","title":"README - Dependencies","type":"extras"},{"doc":"MIT","ref":"readme.html#license","title":"README - License","type":"extras"}]