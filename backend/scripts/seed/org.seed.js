import Organisation from '../../src/models/Organisation.model.js';
import User from '../../src/models/User.model.js';

export async function seedOrganisations() {
  const orgs = [
    { name: 'Global University', type: 'college' },
    { name: 'Tech Institute', type: 'college' },
    { name: 'City High School', type: 'school' }
  ];

  const createdOrgs = [];

  for (const orgData of orgs) {
    let org = await Organisation.findOne({ name: orgData.name });
    if (!org) {
      org = await Organisation.create({
        ...orgData,
        status: 'active',
        subscription: { plan: 'premium', maxTeachers: 500, maxStudents: 10000 }
      });
      console.log(`✅ Organisation created: ${org.name}`);
    } else {
      console.log(`ℹ️ Organisation already exists: ${org.name}`);
    }

    // Create Org Admin for each
    const adminEmail = `admin@${org.name.toLowerCase().replace(/ /g, '')}.com`;
    const adminExists = await User.findOne({ email: adminEmail });
    if (!adminExists) {
      await User.create({
        name: `${orgData.name} Admin`,
        email: adminEmail,
        password: 'AdminPassword123',
        role: 'org_admin',
        organisation: org._id,
        isActive: true
      });
      console.log(`✅ Org Admin created: ${adminEmail}`);
    }

    createdOrgs.push(org);
  }

  return createdOrgs;
}
