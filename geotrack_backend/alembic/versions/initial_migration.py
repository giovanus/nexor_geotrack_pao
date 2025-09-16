"""Initial migration

Revision ID: initial
Revises: 
Create Date: 2023-01-01 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'initial'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    # Création de la table devices
    op.create_table('devices',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('device_id', sa.String(), nullable=False),
        sa.Column('status', sa.String(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_devices_device_id'), 'devices', ['device_id'], unique=True)
    op.create_index(op.f('ix_devices_id'), 'devices', ['id'], unique=False)

    # Création de la table gps_data
    op.create_table('gps_data',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('device_id', sa.String(), nullable=False),
        sa.Column('lat', sa.Float(), nullable=False),
        sa.Column('lon', sa.Float(), nullable=False),
        sa.Column('timestamp', sa.DateTime(timezone=True), nullable=False),
        sa.Column('synced', sa.Boolean(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_gps_data_device_id'), 'gps_data', ['device_id'], unique=False)
    op.create_index(op.f('ix_gps_data_id'), 'gps_data', ['id'], unique=False)

    # Création de la table sync_logs
    op.create_table('sync_logs',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('device_id', sa.String(), nullable=False),
        sa.Column('timestamp', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.Column('status', sa.String(), nullable=False),
        sa.Column('error_message', sa.String(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_sync_logs_device_id'), 'sync_logs', ['device_id'], unique=False)
    op.create_index(op.f('ix_sync_logs_id'), 'sync_logs', ['id'], unique=False)

def downgrade() -> None:
    op.drop_index(op.f('ix_sync_logs_id'), table_name='sync_logs')
    op.drop_index(op.f('ix_sync_logs_device_id'), table_name='sync_logs')
    op.drop_table('sync_logs')
    
    op.drop_index(op.f('ix_gps_data_id'), table_name='gps_data')
    op.drop_index(op.f('ix_gps_data_device_id'), table_name='gps_data')
    op.drop_table('gps_data')
    
    op.drop_index(op.f('ix_devices_id'), table_name='devices')
    op.drop_index(op.f('ix_devices_device_id'), table_name='devices')
    op.drop_table('devices')