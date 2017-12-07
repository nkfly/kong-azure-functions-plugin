# Kong Azure-Functions

A Kong plugin that enables an api endpoint to call Azure Functions.

## Description

This plugin can make the client of Kong call the                       

## Installation

### Development

Navigate to kong/plugins folder and clone this repo

<pre>
$ cd /path/to/kong/plugins
$ git clone https://github.com/nkfly/kong-azure-functions-plugin.git azure-functions
$ cd azure-functions
$ luarocks make *.rockspec
</pre>

To make Kong aware that it has to look for the azure-functions plugin, you'll have to add it to the custom_plugins property in your configuration file.

<pre>
custom_plugins:
    - azure-functions
</pre>

Restart Kong and you're ready to go.

## luarocks

<pre>
$ luarocks install azure-functions
</pre>


## Configuration

You can add the plugin on top of an API by executing the following request on your Kong server:

<pre>
$ curl -X POST http://kong:8001/apis/{api}/plugins \
    --data "name=middleman" \
    --data "config.url=http://myserver.io/validate"
</pre>

<table><thead>
<tr>
<th>form parameter</th>
<th>default</th>
<th>description</th>
</tr>
</thead><tbody>
<tr>
<td><code>name</code></td>
<td></td>
<td>The name of the plugin to use, in this case: <code>middleman</code></td>
</tr>
<tr>
<td><code>config.url</code><br><em>required</em></td>
<td></td>
<td>The URL to which the plugin will make a JSON <code>POST</code> request before proxying the original request.</td>
</tr>
</tbody></table>

Middleman will execute a JSON <code>POST</code> request to the specified <code>url</code> with the following body:

<table>
    <tr>
        <th>Attribute</th>
        <th>Description</th>
    </tr>
    <tr>
    <td><code>body_data</code></td>
    <td><small>The body of the original request</small></td>
    </tr>
    <tr>
        <td><code>url_args</code></td>
        <td><small>The url arguments of the original request</small></td>
    </tr>
    <tr>
        <td><code>headers</code></td>
        <td><small>The headers of the original request</small></td>
    </tr>
</table>

In the scope of your own endpoint, you may validate any of these attributes and accept or reject the request according to your needs.  

## Author
Panagis Tselentis

## License
<pre>
The MIT License (MIT)
=====================

Copyright (c) 2015 Panagis Tselentis

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
</pre>