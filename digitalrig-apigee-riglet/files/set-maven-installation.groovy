a = Jenkins.instance.getExtensionList(hudson.tasks.Maven.DescriptorImpl.class)[0];
b = (a.installations as List);

if (b.size() == 0) {
  b.add(new hudson.tasks.Maven.MavenInstallation("Default", "/opt/maven/apache-maven-3.2.5", []));
  a.installations = b;
  a.save();
}