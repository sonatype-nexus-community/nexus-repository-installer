/*
 * Copyright (c) 2019-present Sonatype, Inc. All rights reserved.
 *
 * This program is licensed to you under the Apache License Version 2.0,
 * and you may not use this file except in compliance with the Apache License Version 2.0.
 * You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the Apache License Version 2.0 is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.
 */

import com.sonatype.nexus.api.common.Authentication
import com.sonatype.nexus.api.common.ServerConfig
import com.sonatype.nexus.api.repository.v3.DefaultAsset
import com.sonatype.nexus.api.repository.v3.DefaultComponent
import com.sonatype.nexus.api.repository.v3.RepositoryManagerV3ClientBuilder

import groovy.cli.commons.CliBuilder

@Grab(group='org.slf4j', module='slf4j-simple', version='1.7.25')
@Grab(group='com.sonatype.nexus', module='nexus-platform-api', version='3.5.20190215-094356.8a0ba7f')

cli = new CliBuilder(usage: 'Repository', expandArgumentFiles: true)
cli.h(type: Boolean, longOpt: 'help', 'Prints this help text')
cli._(longOpt: 'serverurl', 'URL of nexus repository manager server', convert: {URI.create(it)}, required: true)
cli.u(type: String, longOpt: 'username', 'Username', required: true)
cli.p(type: String, longOpt: 'password', 'Password', required: true)
cli.f(type: String, longOpt: 'format', 'Artifact format. Examples: maven2', required: true)
cli._(longOpt: 'filename', 'Filename to upload', convert: {new File(it)}, required: true)
cli.C(args:2, valueSeparator:'=', argName:'key=value', 'Component coordinates, can be used multiple times. Example: ' +
    '-CgroupId=com.example -CartifactId=myapp -Cversion=1.0', required: true)
cli.A(args:2, valueSeparator:'=', argName:'key=value', 'Asset attributes, can be used multiple times. Example: ' +
    '-Aextension=jar -Aclassifier=bin', required: true)
cli.r(type: String, longOpt: 'repository', 'Name of target repository on Nexus. Example: maven-releases', required: true)
cli._(type: String, longOpt: 'tagname', 'The tag to apply (tag must already exist)')
options = cli.parse(args)
if (!options) {
  System.exit(1)
}
if (options.h) {
  cli.usage()
  System.exit(0)
}

// create client
serverConfig = new ServerConfig(options.serverurl, new Authentication(options.username, options.password))
client = new RepositoryManagerV3ClientBuilder().withServerConfig(serverConfig).build()

// utility function to convert attribute list to map
toMap = { list -> (0..list.size()-1).step(2).collectEntries { [(list[it]): list[it+1]] } }

// set component coordinates
component = new DefaultComponent(options.format)
toMap(options.Cs).each { component.addAttribute(it.key, it.value) }

// set asset attributes
asset = new DefaultAsset(options.filename.name, options.filename.newInputStream())
toMap(options.As).each { asset.addAttribute(it.key, it.value) }
component.addAsset(asset)

// upload to nexus repository
client.upload(options.repository, component)
