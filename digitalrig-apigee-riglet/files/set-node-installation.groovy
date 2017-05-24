import hudson.tools.*;
import jenkins.plugins.nodejs.tools.*;

def inst = Jenkins.getInstance();

def desc = inst.getDescriptor(NodeJSInstallation);

if (desc.getInstallations().size() == 0) {
	def installer = new NodeJSInstaller("6.3.1", "", 100);

	def prop = new InstallSourceProperty([installer]);

	def sinst = new NodeJSInstallation("latest", "", [prop]);

	desc.setInstallations(sinst);

	desc.save();
}
