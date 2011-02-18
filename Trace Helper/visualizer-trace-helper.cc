#include "visualizer-trace-helper.h"


using namespace ns3;

VisualizerTraceHelper::VisualizerTraceHelper (unsigned int simulationLengthInMilliseconds,
                         NodeContainer theNodeContainer)
{
  simulationLength = simulationLengthInMilliseconds;
  nodeContainer = theNodeContainer;

  ConnectSinks();
}


VisualizerTraceHelper::~VisualizerTraceHelper ()
{

}


void
VisualizerTraceHelper::CourseChanged (std::string context, Ptr<const MobilityModel> model)
{
  if (!outputStream.is_open())
    return;
  
  int nodeId;
  
  Vector position = model->GetPosition (); // Get the position of the node to trace
  Vector velocity = model->GetVelocity (); // Get the velocity vector of the node
  
  sscanf(context.c_str(), "/NodeList/%i/", &nodeId); // Get its id
  
  // FORMAT: cc <node id> <time> <pos_x> <pos_y> <vel_x> <vel_y>
  
  outputStream << "cc "; // Line type: Course Changed
  outputStream << nodeId << " ";
  outputStream << Simulator::Now ().GetMilliSeconds() << " ";
  outputStream << (int)position.x << " ";
  outputStream << (int)position.y << " ";
  outputStream << velocity.x << " ";
  outputStream << velocity.y;
  outputStream << endl;
}

/**
 * @brief Sink that handles static positioned nodes (Added by Morten)
 */
void
VisualizerTraceHelper::StaticPosition(int nodeId, int x, int y)
{
  if (!outputStream.is_open())
    return;

  // FORMAT: cc <node id> <time> <pos_x> <pos_y> <vel_x> <vel_y>

   outputStream << "cc "; // Line type: Course Changed
   outputStream << nodeId << " ";
   outputStream << Simulator::Now ().GetMilliSeconds() << " ";
   outputStream << x << " ";
   outputStream << y << " ";
   outputStream << 0 << " ";
   outputStream << 0;
   outputStream << endl;
}

void
VisualizerTraceHelper::RouteChanged (std::string text, uint32_t size)
{
  if (!outputStream.is_open())
    return;

  int nodeId;
  
  sscanf(text.c_str(), "/NodeList/%i/", &nodeId); // Get its id
  
  outputStream << "rc "; // Line type: Route Changed
  outputStream << nodeId << " ";
  outputStream << Simulator::Now ().GetMilliSeconds() << " ";
  
  std::vector<GenericRoutingTableEntry> table = nodeContainer.Get (nodeId)->GetObject<CrossLayerInterface> ()->GetGenericRoutingTable ();

  // Iterate through all entries in the table
  for (std::vector<GenericRoutingTableEntry>::iterator it = table.begin(); it != table.end(); it++)
  {
    outputStream << GetNodeIdForAddress(it->GetDestAddr ()) << ",";
    outputStream << GetNodeIdForAddress(it->GetNextAddr ()) << ",";
  }
  
  outputStream << endl;
}


void
VisualizerTraceHelper::MacTransmit (std::string text, Ptr<const Packet> originalPacket)
{
  int nodeId;
  WifiMacHeader macHeader;
  Ptr<Packet> packet;
  Mac48Address nextHopAddress;
  
  // Make a copy of the packet so that it can be modified
  packet = Ptr<Packet>(new Packet(*originalPacket));
  
  // Make a copy of the packet so that it can be modified
  packet = Ptr<Packet>(new Packet(*originalPacket));
  
  // Peek and remove the MAC header
  packet->RemoveHeader (macHeader);
  
  if (!macHeader.IsData())
    return;
  
  nextHopAddress = macHeader.GetAddr1();
  
  sscanf(text.c_str(), "/NodeList/%i/", &nodeId); // Get its id
  
  // Write to file,
  // format: mt <node id> <time> <packet_size> <next_hop_id>
  
  outputStream << "mt "; // Line type: Mac Transmission
  outputStream << nodeId << " ";
  outputStream << Simulator::Now ().GetMilliSeconds() << " ";
  outputStream << packet->GetSize () << " ";
  outputStream << GetNodeIdForAddress(nextHopAddress);
  outputStream << endl;
}


void
VisualizerTraceHelper::MacReceive (std::string text, Ptr<const Packet> originalPacket)
{
  int nodeId;
  LlcSnapHeader llcSnapHeader;
  WifiMacHeader macHeader;
  Ptr<Packet> packet;
  Mac48Address lastHopAddress;
  Mac48Address realDestinationAddress;
  
  // Make a copy of the packet so that it can be modified
  packet = Ptr<Packet>(new Packet(*originalPacket));
  
  // Peek and remove the MAC header
  packet->RemoveHeader (macHeader);
  
  if (!macHeader.IsData())
    return;
  
  realDestinationAddress = macHeader.GetAddr1();
  
  // Read the MAC address of the last hop. We need to guess where it's stored
  switch (macHeader.GetType ())
  {
    case WIFI_MAC_MGT_DEAUTHENTICATION:
    case WIFI_MAC_MGT_ACTION:
    case WIFI_MAC_MGT_ACTION_NO_ACK:
      lastHopAddress = macHeader.GetAddr2();
      break;
    case WIFI_MAC_DATA:
      if (!macHeader.IsToDs() && !macHeader.IsFromDs())
      {
        lastHopAddress = macHeader.GetAddr2();
      }
      else if (!macHeader.IsToDs() && macHeader.IsFromDs())
      {
        lastHopAddress = macHeader.GetAddr3();
      }
      else if (macHeader.IsToDs() && !macHeader.IsFromDs())
      {
        lastHopAddress = macHeader.GetAddr2();
      }
      else if (macHeader.IsToDs() && macHeader.IsFromDs())
      {
        lastHopAddress = macHeader.GetAddr4();
      }
      else
      {
        NS_FATAL_ERROR ("Impossible ToDs and FromDs flags combination");
      }
      break;
    default:
      return;
  }
  
  sscanf(text.c_str(), "/NodeList/%i/", &nodeId); // Get its id
  
  // Write to file,
  // format: mr <node id> <time> <packet_size> <last_hop_id> <next_hop_id>
  
  outputStream << "mr "; // Line type: Mac Reception
  outputStream << nodeId << " ";
  outputStream << Simulator::Now ().GetMilliSeconds() << " ";
  outputStream << packet->GetSize () << " ";
  outputStream << GetNodeIdForAddress(lastHopAddress) << " ";
  outputStream << GetNodeIdForAddress(realDestinationAddress);
  outputStream << endl;
}


void
VisualizerTraceHelper::MacDrop (std::string text, Ptr<const Packet> packet)
{
  int nodeId;
  
  sscanf(text.c_str(), "/NodeList/%i/", &nodeId); // Get its id
  
  // Write to file,
  // format: md <node id> <time>
  
  outputStream << "md "; // Line type: Mac Drop
  outputStream << nodeId << " ";
  outputStream << Simulator::Now ().GetMilliSeconds() << " ";
  outputStream << endl;
}


void
VisualizerTraceHelper::QueueChange (std::string text, int nPackets)
{
   int nodeId;
  
  sscanf(text.c_str(), "/NodeList/%i/", &nodeId); // Get its id
  
  // Write to file,
  // format: be <node id> <time> <new_queue_size>
  
  outputStream << "be "; // Line type: Buffer Enqueue
  outputStream << nodeId << " ";
  outputStream << Simulator::Now ().GetMilliSeconds() << " ";
  outputStream << nPackets;
  outputStream << endl;
}


void
VisualizerTraceHelper::ManualTrace (std::string text)
{
  outputStream << text.c_str() << endl;
}

void
VisualizerTraceHelper::PeriodicBufferSizeUpdate ()
{
  int j = 0;
  for (NodeContainer::Iterator i = nodeContainer.Begin (); i != nodeContainer.End (); ++i)
  {
      outputStream << "be "; // Line type: Buffer Enqueue
      outputStream << j << " ";
      outputStream << Simulator::Now ().GetMilliSeconds() << " ";
      outputStream << (*i)->GetObject<ResourceManager> ()->GetQueuedPacketCount ();
      outputStream << endl;
      j++;
  }

  // Repeat each second..
  Simulator::Schedule (Seconds(1.0), &VisualizerTraceHelper::PeriodicBufferSizeUpdate, this);
}


void
VisualizerTraceHelper::StartWritingFile (std::string filename, std::ios::openmode filemode)
{
  outputStream.open(filename.c_str(), filemode);
  
  // Write the length of the simulation
  outputStream << "s " << simulationLength << endl;
}


void
VisualizerTraceHelper::EndWritingFile ()
{
  outputStream.close();
}


void
VisualizerTraceHelper::ConnectSinks()
{
  // Connect sources with sinks
  Config::Connect ("/NodeList/*/$ns3::MobilityModel/CourseChange",
    MakeCallback (&VisualizerTraceHelper::CourseChanged, this));
  Config::Connect("/NodeList/*/$ns3::olsr::RoutingProtocol/RoutingTableChanged",
    MakeCallback (&VisualizerTraceHelper::RouteChanged, this));
  Config::Connect ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Phy/PhyTxBegin",
    MakeCallback (&VisualizerTraceHelper::MacTransmit, this));
  Config::Connect("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Phy/PhyRxEnd",
    MakeCallback (&VisualizerTraceHelper::MacReceive, this));
  Config::Connect ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/$ns3::AdhocWifiMac/MacTxDrop",
    MakeCallback (&VisualizerTraceHelper::MacDrop, this));
  Config::Connect ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/$ns3::AdhocWifiMac/MacRxDrop",
    MakeCallback (&VisualizerTraceHelper::MacDrop, this));
  Config::Connect("/NodeList/*/ApplicationList/*/$ns3::DtsOverlay/Enqueue",
    MakeCallback (&VisualizerTraceHelper::QueueChange, this));

  // Added by Morten.
  Simulator::Schedule (Seconds(1.0), &VisualizerTraceHelper::PeriodicBufferSizeUpdate,this);
}



// TODO Create a dictionary of address - nodeId
int
VisualizerTraceHelper::GetNodeIdForAddress(Ipv4Address address)
{
  NodeContainer::Iterator it;
  
  // Iterate through all nodes
  for (it = nodeContainer.Begin();
       it != nodeContainer.End();
       it++)
  {
    // Check if the addresses match
    Ipv4Address nodeAddr = (*it)->GetObject<Ipv4>()->GetAddress(1,0).GetLocal();
    if (address == nodeAddr)
      break;
  }
  
  // If there has been a match, we return the node's id
  if (it != nodeContainer.End())
  {
    return (*it)->GetId();
  }
  
  return -1;
}

int
VisualizerTraceHelper::GetNodeIdForAddress(Mac48Address address)
{
  NodeContainer::Iterator it;
  
  // Iterate through all nodes
  for (it = nodeContainer.Begin();
       it != nodeContainer.End();
       it++)
  {
    // Check if the addresses match
    Ptr<WifiNetDevice> netDevice = DynamicCast<WifiNetDevice> ((*it)->GetDevice(0));
    Mac48Address nodeAddr = netDevice->GetMac()->GetAddress();
    
    if (address == nodeAddr)
      break;
  }
  
  // If there has been a match, we return the node's id
  if (it != nodeContainer.End())
  {
    return (*it)->GetId();
  }
  
  return -1;
}
