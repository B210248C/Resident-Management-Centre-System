const crypto = require('crypto');
const express = require('express');
const admin = require('firebase-admin');
const app = express();
const serviceAccount = require('./service-account-key.json'); // Replace with the path to your Firebase service account key

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

app.use(express.json());

// Endpoint to generate invitation codes
app.post('/generate-invitation', async (req, res) => {
  const { role, expiration } = req.body; // role and expiration should be sent from the client
  const token = crypto.randomBytes(8).toString('hex'); // Generate a unique token
  const expirationDate = new Date(Date.now() + expiration * 60000); // expiration in minutes

  try {
    await db.collection('invitationTokens').doc(token).set({
      role,
      isUsed: false,
      expirationDate: admin.firestore.Timestamp.fromDate(expirationDate),
    });
    res.json({ token });
  } catch (error) {
    console.error('Error generating invitation:', error);
    res.status(500).send('Error generating invitation code');
  }
});

// Endpoint to verify invitation codes
app.post('/verify-token', async (req, res) => {
  const { token } = req.body;

  try {
    const doc = await db.collection('invitationTokens').doc(token).get();
    if (!doc.exists) {
      return res.json({ isValid: false });
    }

    const data = doc.data();
    if (data.isUsed || data.expirationDate.toDate() < new Date()) {
      return res.json({ isValid: false });
    }

    // Mark token as used
    await db.collection('invitationTokens').doc(token).update({ isUsed: true });
    res.json({ isValid: true, role: data.role });
  } catch (error) {
    console.error('Error verifying token:', error);
    res.status(500).send('Error verifying invitation code');
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
