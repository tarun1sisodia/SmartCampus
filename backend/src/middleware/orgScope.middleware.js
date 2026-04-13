export default (req, res, next) => {
  if (req.user.role === 'super_admin') {
    req.scope = { isSuperAdmin: true };
    return next();
  }

  if (!req.user.organisation) {
    return res.status(403).json({ success: false, message: 'User does not belong to any organisation' });
  }

  req.scope = { organisationId: req.user.organisation, isSuperAdmin: false };
  next();
};
