const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');
initializeApp();

const TOPIC = 'all_residents';

exports.notifyResidentsOnAnnouncement = onDocumentCreated(
  'announcements/{announcementId}',
  async (event) => {
    const data = event.data?.data() || {};
    const type = data.type || 'public_notice';
    const customTag = data.customTag || '';
    const title =
      type === 'custom_tag' && customTag
        ? customTag
        : type.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());

    const bodyPreview =
      typeof data.body === 'string'
        ? data.body.slice(0, 120)
        : 'New barangay announcement';

    await getMessaging().send({
      topic: TOPIC,
      notification: {
        title: `BarangayBoard: ${title}`,
        body: bodyPreview,
      },
      android: {
        priority: 'high',
        notification: { channelId: 'barangay_announcements' },
      },
    });

    return null;
  },
);
